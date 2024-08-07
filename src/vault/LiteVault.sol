// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../interfaces/IAuthorize.sol";
import "../interfaces/IVault.sol";

/**
 * @title LiteVault
 * @notice A simple vault that allows users to deposit and withdraw tokens.
 */
// TODO: (LANG/OPT) it is better to use custom errors instead of revert strings.
contract LiteVault is IVault, ReentrancyGuard {
    /// @dev Using SafeERC20 to support non fully ERC20-compliant tokens,
    /// that may not return a boolean value on success.
    using SafeERC20 for IERC20;

    // Mapping from user to token to balances
    mapping(address => mapping(address => uint256)) internal _balances;

    IAuthorize public authorizer;
    address public immutable owner;

    /**
     * @dev Modifier to check if the caller is the owner of the contract.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    /**
     * @dev Constructor sets the initial owner of the contract.
     */
    constructor(address owner_) {
        owner = owner_;
    }

    /**
     * @dev Function to receive Ether. msg.data must be empty.
     */
    receive() external payable {}

    /**
     * @dev Fallback function is called when msg.data is not empty.
     */
    fallback() external payable {}

    /**
     * @dev Sets the authorizer contract.
     * @param newAuthorizer The address of the authorizer contract.
     */
    function setAuthorizer(IAuthorize newAuthorizer) external onlyOwner {
        authorizer = newAuthorizer;
    }

    /**
     * @dev Deposits tokens or ETH into the vault.
     * @param token The address of the token to deposit. Use address(0) for ETH.
     * @param amount The amount of tokens or ETH to deposit.
     */
    function deposit(address token, uint256 amount) public payable override {
        if (token == address(0)) {
            require(msg.value == amount, "Incorrect amount of ETH sent");
            _balances[msg.sender][address(0)] += amount;
        } else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
            _balances[msg.sender][token] += amount;
        }

        emit Deposited(msg.sender, token, amount);
    }

    /**
     * @dev Withdraws tokens or ETH from the vault.
     * @param token The address of the token to withdraw. Use address(0) for ETH.
     * @param amount The amount of tokens or ETH to withdraw.
     */
    function withdraw(
        address token,
        uint256 amount
    ) external override nonReentrant {
        uint256 currentBalance = _balances[msg.sender][token];
        require(currentBalance >= amount, "Insufficient balance");
        require(
            authorizer.authorize(msg.sender, token, amount),
            "Authorization failed"
        );

        _balances[msg.sender][token] -= amount;

        if (token == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }

        emit Withdrawn(msg.sender, token, amount);
    }

    /**
     * @dev Returns the balance of the specified token for a user.
     * @param user The address of the user.
     * @param token The address of the token. Use address(0) for ETH.
     * @return The balance of the specified token for the user.
     */
    function balanceOf(
        address user,
        address token
    ) public view override returns (uint256) {
        return _balances[user][token];
    }
}
