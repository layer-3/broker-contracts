// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../interfaces/IAuthorize.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title CooldownAuthorizer
 * @notice Authorizer contract that enforces a cooldown period before withdrawals.
 * @dev Users must request a withdrawal which starts a cooldown period.
 *      After the cooldown period has passed, the withdrawal is authorized.
 *      Supports multiple cooldown periods that can be enabled/disabled by the owner.
 */
contract CooldownAuthorizer is IAuthorize, Ownable2Step {
    /**
     * @notice Struct to store withdrawal request information.
     * @param amount The amount of tokens requested for withdrawal.
     * @param requestTimestamp The timestamp when the withdrawal was requested.
     * @param cooldownPeriod The cooldown period chosen for this withdrawal request.
     */
    struct WithdrawalRequest {
        uint256 amount;
        uint64 requestTimestamp;
        uint64 cooldownPeriod;
    }

    /**
     * @notice Error thrown when the withdrawal amount exceeds the requested amount.
     * @param requested The amount that was requested for withdrawal.
     * @param attempted The amount that was attempted to be withdrawn.
     */
    error ExceedsRequestedAmount(uint256 requested, uint256 attempted);

    /**
     * @notice Error thrown when the cooldown period has not yet passed.
     * @param requestTimestamp The timestamp when the withdrawal was requested.
     * @param currentTimestamp The current timestamp.
     * @param cooldownPeriod The required cooldown period.
     */
    error CooldownNotExpired(
        uint64 requestTimestamp,
        uint64 currentTimestamp,
        uint64 cooldownPeriod
    );

    /**
     * @notice Error thrown when the withdrawal has not been requested.
     * @param user The address of the user.
     * @param token The address of the token.
     */
    error WithdrawalNotRequested(address user, address token);

    /**
     * @notice Error thrown when the requested cooldown period is not supported.
     * @param cooldownPeriod The cooldown period that was requested.
     */
    error UnsupportedCooldownPeriod(uint64 cooldownPeriod);

    /**
     * @notice Error thrown when the cooldown period is invalid.
     */
    error InvalidCooldownPeriod();

    /**
     * @notice Event emitted when a withdrawal is requested.
     * @param user The address of the user requesting the withdrawal.
     * @param token The address of the token to withdraw.
     * @param amount The amount of tokens to withdraw.
     * @param cooldownPeriod The cooldown period chosen for this withdrawal request.
     */
    event CooldownRequested(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint64 cooldownPeriod
    );

    /**
     * @notice Event emitted when a cooldown period's status is updated.
     * @param cooldownPeriod The cooldown period that was updated.
     * @param isSupported Whether the cooldown period is now supported.
     */
    event CooldownPeriodStatusChanged(uint64 cooldownPeriod, bool isSupported);

    // Mapping of cooldown period to whether it is supported
    mapping(uint64 cooldownPeriod => bool isSupported)
        private _supportedCooldownPeriods;

    // Mapping of user address to token address to withdrawal request
    mapping(address user => mapping(address token => WithdrawalRequest request))
        private _withdrawalRequests;

    /**
     * @dev Constructor sets the initial owner of the contract and enables the provided cooldown periods.
     * @param owner The address of the owner.
     * @param supportedCooldownPeriods Array of cooldown periods to be initially supported.
     */
    constructor(
        address owner,
        uint64[] memory supportedCooldownPeriods
    ) Ownable(owner) {
        for (uint256 i = 0; i < supportedCooldownPeriods.length; i++) {
            uint64 period = supportedCooldownPeriods[i];
            require(period > 0, InvalidCooldownPeriod());
            _supportedCooldownPeriods[period] = true;
            emit CooldownPeriodStatusChanged(period, true);
        }
    }

    /**
     * @notice Checks if a cooldown period is supported.
     * @param cooldownPeriod The cooldown period to check.
     * @return True if the cooldown period is supported, false otherwise.
     */
    function isCooldownPeriodSupported(
        uint64 cooldownPeriod
    ) external view returns (bool) {
        return _supportedCooldownPeriods[cooldownPeriod];
    }

    /**
     * @notice Get the withdrawal request details for a user and token.
     * @param user The address of the user.
     * @param token The address of the token.
     * @return amount The amount of tokens requested for withdrawal.
     * @return requestTimestamp The timestamp when the withdrawal was requested.
     * @return cooldownPeriod The cooldown period chosen for this withdrawal request.
     */
    function getWithdrawalRequest(
        address user,
        address token
    )
        external
        view
        returns (uint256 amount, uint64 requestTimestamp, uint64 cooldownPeriod)
    {
        WithdrawalRequest memory request = _withdrawalRequests[user][token];
        return (
            request.amount,
            request.requestTimestamp,
            request.cooldownPeriod
        );
    }

    /**
     * @notice Check if a withdrawal is authorized.
     * @dev Returns true if the cooldown period has passed since the withdrawal request.
     * @param owner The address of the token owner.
     * @param token The address of the token.
     * @param amount The amount of tokens to be withdrawn.
     * @return True if the withdrawal is authorized, false otherwise.
     */
    function authorize(
        address owner,
        address token,
        uint256 amount
    ) external view override returns (bool) {
        WithdrawalRequest memory request = _withdrawalRequests[owner][token];

        // Check if withdrawal was requested
        require(
            request.requestTimestamp != 0,
            WithdrawalNotRequested(owner, token)
        );

        // Check if amount is less than or equal to requested amount
        require(
            amount <= request.amount,
            ExceedsRequestedAmount(request.amount, amount)
        );

        // Check if cooldown period has passed
        // Note: We don't check if the cooldown period is still supported
        require(
            uint64(block.timestamp) >=
                request.requestTimestamp + request.cooldownPeriod,
            CooldownNotExpired(
                request.requestTimestamp,
                uint64(block.timestamp),
                request.cooldownPeriod
            )
        );

        return true;
    }

    /**
     * @notice Updates the status of a cooldown period.
     * @param cooldownPeriod The cooldown period to update.
     * @param isSupported Whether the cooldown period should be supported.
     */
    function setCooldownPeriodStatus(
        uint64 cooldownPeriod,
        bool isSupported
    ) external onlyOwner {
        require(cooldownPeriod > 0, InvalidCooldownPeriod());
        _supportedCooldownPeriods[cooldownPeriod] = isSupported;
        emit CooldownPeriodStatusChanged(cooldownPeriod, isSupported);
    }

    /**
     * @notice Request a withdrawal for a specific token and amount with a specific cooldown period.
     * @dev Emits a CooldownRequested event.
     * @param token The address of the token to withdraw.
     * @param amount The amount of tokens to withdraw.
     * @param cooldownPeriod The cooldown period to use for this withdrawal request.
     */
    function requestWithdrawalWithCooldown(
        address token,
        uint256 amount,
        uint64 cooldownPeriod
    ) public {
        require(
            _supportedCooldownPeriods[cooldownPeriod],
            UnsupportedCooldownPeriod(cooldownPeriod)
        );

        _withdrawalRequests[msg.sender][token] = WithdrawalRequest({
            amount: amount,
            requestTimestamp: uint64(block.timestamp),
            cooldownPeriod: cooldownPeriod
        });

        emit CooldownRequested(msg.sender, token, amount, cooldownPeriod);
    }
}
