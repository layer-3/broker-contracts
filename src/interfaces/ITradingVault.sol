// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// interface IFundingSource {
//   allowance(address token, address owner, address spender) external view returns (uint256);
//   setAllowanceFor(address token, address spender, uint256 amount) external;
//   pullFrom(address otherFundingSource, address token, address owner, uint256 amount) external;
//   transferTo(address token, address to, uint256 amount) external;
// }

interface ITradingStructs {
    /// @notice Defines where account's funds are taken from and sent to.
    enum FundingLocation {
        // TODO: maybe rename to "External", that will need to implement a specific interface, that allows pulling funds
        // This way:
        // 1. both TradingVault and LiquidityMiningVault are the same funding source.
        // 2. other External funding sources can be easily added.
        // This also requires passing an additional "address" parameter, to know which source to pull funds from.

        // What if the "FundingSource" is an address? This way, if the "trader" == "fundingSource", the funds are taken from the trader's balance.
        // Otherwise, the contract at the "fundingSource" address is called to pull funds from the trader's balance.

        // Continuing this idea, "pulling funds" is basically calling "asset.TransferFrom(from, to, amount)",
        // and means there is no need to differentiate between `Account` and `External` funding sources.
        // NOTE: ETH does not have "transferFrom" method, so it must be handled separately or used Wrapped.
        // Having said that, all funding sources must support an "approval" feature, including TradingVault and LiquidityMiningVault.
        // Also, in case trader and broker settle between different EFSs, each of them must be aware when funds are transferred to them.
        // This is impossible to achieve with a simple ERC20 transfer, therefore, EFSs must implement a specific interface that
        // not only transfer funds, but if a destination is another EFS, it must notify the destination about the transfer.
        // This can be done by calling a destination EFS and asking it to pull funds.

        // even if the funding source of both actors is the same, it will pull funds from itself successfully.

        // The problem is that in such case users in each EFS must approve funds to all possible other EFSs, which is not convenient.
        // A move convenient method would be for the TradingVault to orchestrate this process like an intermediary.
        // This way, users will need to approve funds in their respective EFSs only to the TradingVault, and the TradingVault will
        // handle the exchange.

        // This also solves the transfer from an Address to an EFS, as the Address will approve the TradingVault to pull funds from it,
        // and the TradingVault will handle the transfer to the EFS.

        /// @dev funds are taken from the TradingVault account's balance
        TradingVault,
        /// @dev funds are pulled from the account's token balance
        Address
    }

    struct Session {
        bool isActive;
        uint256 nonce;
    }

    struct Allocation {
        address asset;
        uint256 amount;
    }

    struct Funding {
        Allocation allocation;
        FundingLocation source;
    }

    struct Intent {
        address trader;
        Allocation[] allocations;
        uint256 nonce;
    }

    struct Outcome {
        address trader;
        // NOTE: can be extended to a funding source per position
        FundingLocation traderFundingDestination;
        FundingLocation brokerFundingDestination;
        Funding[] traderGives;
        Funding[] brokerGives;
        uint256 nonce;
    }
}

/**
 * @title ITradingTerminal
 * @author nksazonov
 * @notice An ownerful implementation of a trading terminal that allows to start and end trading sessions, settle traders and liquidate.
 */
interface ITradingVault {
    event Deposited(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event Withdrawn(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    event Settled(address indexed trader, uint256 nonce);
    event Liquidated(address indexed trader, uint256 nonce);

    error InvalidAddress();
    error IncorrectValue();
    error InvalidAmount();
    error InsufficientBalance(
        address token,
        uint256 required,
        uint256 available
    );
    error NativeTransferFailed();

    error InvalidSignature();
    error NonceMismatch(uint256 expected, uint256 actual);
    error InvalidFundingLocation();
    error InvalidAssetOutcome();

    function balanceOf(
        address user,
        address token
    ) external view returns (uint256);

    function balancesOfTokens(
        address user,
        address[] calldata tokens
    ) external view returns (uint256[] memory);

    // NOTE: added a possibility to batch-deposit
    function deposit(ITradingStructs.Intent calldata intent) external payable;

    function withdraw(
        ITradingStructs.Intent calldata intent,
        bytes calldata brokerSig
    ) external;

    function settle(
        ITradingStructs.Outcome calldata outcome,
        bytes calldata brokerSig
    ) external;

    /// @param brokerSig Broker signature over the incremented nonce of a latest settlement (either completed or liquidated)
    function liquidate(
        ITradingStructs.Outcome calldata outcome,
        bytes calldata brokerSig
    ) external;
}
