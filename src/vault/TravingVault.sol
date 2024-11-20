// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ITradingStructs, ITradingVault} from "../interfaces/ITradingVault.sol";
import {IAuthorizeV2} from "../interfaces/IAuthorizeV2.sol";
import {IAuthorizableV2} from "../interfaces/IAuthorizableV2.sol";

contract TradingVault is ITradingVault, IAuthorizableV2, ReentrancyGuard, Ownable2Step {
    /// @dev Using SafeERC20 to support non fully ERC20-compliant tokens,
    /// that may not return a boolean value on success.
    using SafeERC20 for IERC20;

    mapping(address user => mapping(address token => uint256 balance)) internal _balances;
    mapping(address user => uint256 session) internal _nonces;

    address public broker;
    IAuthorizeV2 public authorizer;

    modifier notZeroAddress(address addr) {
        require(addr != address(0), InvalidAddress());
        _;
    }

    constructor(address owner, address broker_, IAuthorizeV2 authorizer_) Ownable(owner) {
        broker = broker_;
        authorizer = authorizer_;
    }

    // ---------- View functions ----------

    function balanceOf(address user, address token) external view returns (uint256) {
        return _balances[user][token];
    }

    function balancesOfTokens(address user, address[] calldata tokens) external view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            balances[i] = _balances[user][tokens[i]];
        }
        return balances;
    }

    // ---------- Owner functions ----------

    function setBroker(address broker_) external onlyOwner {
        broker = broker_;
    }

    function setAuthorizer(IAuthorizeV2 newAuthorizer) external onlyOwner {
        if (address(newAuthorizer) == address(0)) {
            revert InvalidAddress();
        }

        authorizer = newAuthorizer;
        emit AuthorizerChanged(newAuthorizer);
    }

    // ---------- Write functions ----------

    function deposit(ITradingStructs.Intent calldata intent) external payable notZeroAddress(intent.trader) {
        address sender = msg.sender;
        address recipient = intent.trader;
        uint256 nonce = _nonces[recipient];
        require(nonce == intent.nonce, NonceMismatch(nonce, intent.nonce));

        _nonces[recipient]++;

        for (uint256 i = 0; i < intent.allocations.length; i++) {
            address token = intent.allocations[i].asset;
            uint256 amount = intent.allocations[i].amount;
            require(amount > 0, InvalidAmount());

            if (token == address(0)) {
                require(msg.value == amount, IncorrectValue());
                _balances[recipient][address(0)] += amount;
            } else {
                require(msg.value == 0, IncorrectValue());
                _balances[recipient][token] += amount;
                IERC20(token).safeTransferFrom(sender, address(this), amount);
            }

            emit Deposited(recipient, token, amount);
        }
    }

    function withdraw(
        ITradingStructs.Intent calldata intent,
        bytes calldata additionalAuthData
    ) external notZeroAddress(intent.trader) {
        address account = intent.trader;
        uint256 nonce = _nonces[account];
        require(nonce == intent.nonce, NonceMismatch(nonce, intent.nonce));

        bytes memory authData = abi.encodePacked(
            ITradingVault.withdraw.selector,
            abi.encode(intent, additionalAuthData)
        );
        require(authorizer.authorize(authData), IAuthorizeV2.Unauthorized(authData));

        // TODO: do we need seasons support here?
        // if (
        //     !_isWithdrawalGracePeriodActive(
        //         latestSetAuthorizerTimestamp, uint64(block.timestamp), WITHDRAWAL_GRACE_PERIOD
        //     ) && !authorizer.authorize(msg.sender, token, amount)
        // ) {
        //     revert IAuthorize.Unauthorized(msg.sender, token, amount);
        // }

        _nonces[account]++;

        for (uint256 i = 0; i < intent.allocations.length; i++) {
            address asset = intent.allocations[i].asset;
            uint256 amount = intent.allocations[i].amount;
            uint256 currentBalance = _balances[account][asset];
            require(currentBalance >= amount, InsufficientBalance(asset, amount, currentBalance));

            _balances[account][asset] -= amount;

            if (asset == address(0)) {
                /// @dev using `call` instead of `transfer` to overcome 2300 gas ceiling that could make it revert with some AA wallets
                (bool success, ) = account.call{value: amount}("");
                require(success, NativeTransferFailed());
            } else {
                IERC20(asset).safeTransfer(account, amount);
            }

            emit Withdrawn(account, asset, amount);
        }
    }

    function settle(ITradingStructs.Outcome calldata outcome, bytes calldata additionalAuthData) external {
        uint256 nonce = _nonces[outcome.trader];
        require(nonce == outcome.nonce, NonceMismatch(nonce, outcome.nonce));
        bytes memory authData = abi.encodePacked(
            ITradingVault.settle.selector,
            abi.encode(outcome, additionalAuthData)
        );
        require(authorizer.authorize(authData), IAuthorizeV2.Unauthorized(authData));

        _nonces[outcome.trader]++;

        _sendAssets(outcome.trader, broker, outcome.brokerFundingDestination, outcome.traderGives);
        _sendAssets(broker, outcome.trader, outcome.traderFundingDestination, outcome.brokerGives);

        emit Settled(outcome.trader, nonce - 1);
    }

    function liquidate(
        ITradingStructs.Outcome calldata outcome,
        bytes calldata additionalAuthData
    ) external notZeroAddress(outcome.trader) {
        require(
            outcome.traderFundingDestination == ITradingStructs.FundingLocation.TradingVault,
            InvalidFundingLocation()
        );
        require(outcome.brokerGives.length == 0, InvalidAssetOutcome());
        uint256 nonce = _nonces[outcome.trader];
        require(nonce == outcome.nonce, NonceMismatch(nonce, outcome.nonce));

        bytes memory authData = abi.encodePacked(
            ITradingVault.liquidate.selector,
            abi.encode(outcome, additionalAuthData)
        );
        require(authorizer.authorize(authData), IAuthorizeV2.Unauthorized(authData));

        _nonces[outcome.trader]++;

        _sendAssets(outcome.trader, broker, outcome.brokerFundingDestination, outcome.traderGives);

        emit Liquidated(outcome.trader, nonce - 1);
    }

    // ---------- Internal functions ----------

    function _checkAndVaultSwap(
        address sender,
        address receiver,
        ITradingStructs.Allocation memory alloc
    ) internal virtual {
        uint256 balance = _balances[sender][alloc.asset];
        require(balance >= alloc.amount, InsufficientBalance(alloc.asset, alloc.amount, balance));

        _balances[sender][alloc.asset] -= alloc.amount;
        _balances[receiver][alloc.asset] += alloc.amount;
    }

    function _checkAndVaultSendAccount(
        address sender,
        address receiver,
        ITradingStructs.Allocation memory alloc
    ) internal virtual {
        uint256 balance = _balances[sender][alloc.asset];
        require(balance >= alloc.amount, InsufficientBalance(alloc.asset, alloc.amount, balance));

        _balances[sender][alloc.asset] -= alloc.amount;
        _balances[receiver][alloc.asset] += alloc.amount;
    }

    function _accountSendVault(
        address sender,
        address receiver,
        ITradingStructs.Allocation memory alloc
    ) internal virtual {
        IERC20(alloc.asset).safeTransferFrom(sender, address(this), alloc.amount);
        _balances[receiver][alloc.asset] += alloc.amount;
    }

    function _accountSwap(address sender, address receiver, ITradingStructs.Allocation memory alloc) internal virtual {
        IERC20(alloc.asset).safeTransferFrom(sender, receiver, alloc.amount);
    }

    function _sendAssets(
        address sender,
        address receiver,
        ITradingStructs.FundingLocation receiverFD,
        ITradingStructs.Funding[] memory senderGives
    ) internal {
        for (uint256 i = 0; i < senderGives.length; i++) {
            ITradingStructs.Funding memory senderFunding = senderGives[i];
            if (senderFunding.source == ITradingStructs.FundingLocation.TradingVault) {
                if (receiverFD == ITradingStructs.FundingLocation.TradingVault) {
                    _checkAndVaultSwap(sender, receiver, senderFunding.allocation);
                } else {
                    _checkAndVaultSendAccount(sender, receiver, senderFunding.allocation);
                }
            } else {
                if (receiverFD == ITradingStructs.FundingLocation.TradingVault) {
                    _accountSendVault(sender, receiver, senderFunding.allocation);
                } else {
                    _accountSwap(sender, receiver, senderFunding.allocation);
                }
            }
        }
    }
}
