// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interfaces/IAuthorize.sol";
import "../interfaces/IAuthorizable.sol";
import "../interfaces/IVault.sol";

/**
 * @title LiteVault
 * @notice A simple vault that allows users to deposit and withdraw tokens.
 */
contract LiteVault is IVault, IAuthorizable, ReentrancyGuard, Ownable2Step {
    /// @dev Using SafeERC20 to support non fully ERC20-compliant tokens,
    /// that may not return a boolean value on success.
    using SafeERC20 for IERC20;

    uint64 public constant WITHDRAWAL_GRACE_PERIOD = 3 days;

    mapping(address user => mapping(address token => uint256 balance)) internal _balances;

    IAuthorize public authorizer;
    uint64 public latestSetAuthorizerTimestamp;

    /**
     * @dev Constructor sets the initial owner of the contract.
     */
    constructor(address owner, IAuthorize authorizer_) Ownable(owner) {
        if (address(authorizer_) == address(0)) {
            revert InvalidAddress();
        }
        authorizer = authorizer_;
    }

    /**
     * @dev Returns the balance of the specified token for a user.
     * @param user The address of the user.
     * @param token The address of the token. Use address(0) for ETH.
     * @return The balance of the specified token for the user.
     */
    function balanceOf(address user, address token) external view returns (uint256) {
        return _balances[user][token];
    }

    /**
     * @dev Returns the balances of multiple tokens for a user.
     * @param user The address of the user.
     * @param tokens The addresses of the tokens. Use address(0) for ETH.
     * @return The balances of the specified tokens for the user.
     */
    function balancesOfTokens(address user, address[] calldata tokens) external view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            balances[i] = _balances[user][tokens[i]];
        }
        return balances;
    }

    /**
     * @dev Sets the authorizer contract.
     * @param newAuthorizer The address of the authorizer contract.
     */
    function setAuthorizer(IAuthorize newAuthorizer) external onlyOwner {
        if (address(newAuthorizer) == address(0)) {
            revert InvalidAddress();
        }

        authorizer = newAuthorizer;
        latestSetAuthorizerTimestamp = uint64(block.timestamp);
        emit AuthorizerChanged(newAuthorizer);
    }

    // TODO: add `customData` as parameter
    // TODO: add a call to authorizer for better flexibility
    // TODO: change `msg.sender` to `account` for more flexibility
    /**
     * @dev Deposits tokens or ETH into the vault.
     * @param token The address of the token to deposit. Use address(0) for ETH.
     * @param amount The amount of tokens or ETH to deposit.
     */
    function deposit(address token, uint256 amount) external payable nonReentrant {
        if (token == address(0)) {
            if (msg.value != amount) revert IncorrectValue();
            _balances[msg.sender][address(0)] += amount;
        } else {
            if (msg.value != 0) revert IncorrectValue();
            _balances[msg.sender][token] += amount;
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }

        emit Deposited(msg.sender, token, amount);
    }

    // TODO: add `customData` as parameter
    /**
     * @dev Withdraws tokens or ETH from the vault.
     * @param token The address of the token to withdraw. Use address(0) for ETH.
     * @param amount The amount of tokens or ETH to withdraw.
     */
    function withdraw(address token, uint256 amount) external nonReentrant {
        uint256 currentBalance = _balances[msg.sender][token];
        if (currentBalance < amount) {
            revert InsufficientBalance(token, amount, currentBalance);
        }
        if (
            // TODO: change method signature to pass `data` as a parameter, that an authorizer can decode and make a decision
            !_isWithdrawalGracePeriodActive(
                latestSetAuthorizerTimestamp, uint64(block.timestamp), WITHDRAWAL_GRACE_PERIOD
            ) && !authorizer.authorize(msg.sender, token, amount)
        ) {
            revert IAuthorize.Unauthorized(msg.sender, token, amount);
        }

        _balances[msg.sender][token] -= amount;

        if (token == address(0)) {
            /// @dev using `call` instead of `transfer` to overcome 2300 gas ceiling that could make it revert with some AA wallets
            (bool success,) = msg.sender.call{value: amount}("");
            if (!success) {
                revert NativeTransferFailed();
            }
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }

        emit Withdrawn(msg.sender, token, amount);
    }

    /**
     * @notice Returns whether the withdrawal grace period is active, i.e. whether a user can withdraw without authorization.
     * @param latestSetAuthorizerTimestamp_ Timestamp when the authorizer was last set.
     * @param now_ Timestamp when the check is performed.
     * @param gracePeriod The duration of the grace period.
     */
    function _isWithdrawalGracePeriodActive(uint64 latestSetAuthorizerTimestamp_, uint64 now_, uint64 gracePeriod)
        internal
        pure
        returns (bool)
    {
        return latestSetAuthorizerTimestamp_ + gracePeriod > now_;
    }
}
