// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../interfaces/IAuthorize.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title UnbondingPeriodAuthorizer
 * @notice Authorizer contract that enforces an unbonding period before withdrawals.
 * @dev Users must request a withdrawal which starts an unbonding period.
 *      After the unbonding period has passed, the withdrawal is authorized.
 *      Supports multiple unbonding periods that can be enabled/disabled by the owner.
 */
contract UnbondingPeriodAuthorizer is IAuthorize, Ownable2Step {
    // Use EnumerableSet for tracking supported unbonding periods
    using EnumerableSet for EnumerableSet.UintSet;
    /**
     * @notice Struct to store withdrawal request information.
     * @param requestTimestamp The timestamp when the withdrawal was requested.
     * @param unbondingPeriod The unbonding period chosen for this withdrawal request.
     */
    struct UnbondingRequest {
        uint64 requestTimestamp;
        uint64 unbondingPeriod;
    }

    /**
     * @notice Error thrown when the unbonding period has not yet passed.
     * @param requestTimestamp The timestamp when the withdrawal was requested.
     * @param currentTimestamp The current timestamp.
     * @param unbondingPeriod The required unbonding period.
     */
    error UnbondingPeriodNotExpired(
        uint64 requestTimestamp,
        uint64 currentTimestamp,
        uint64 unbondingPeriod
    );

    /**
     * @notice Error thrown when the withdrawal has not been requested.
     * @param user The address of the user.
     * @param token The address of the token.
     */
    error UnbondingNotRequested(address user, address token);

    /**
     * @notice Error thrown when the requested unbonding period is not supported.
     * @param unbondingPeriod The unbonding period that was requested.
     */
    error UnsupportedUnbondingPeriod(uint64 unbondingPeriod);

    /**
     * @notice Error thrown when the unbonding period is invalid.
     */
    error InvalidUnbondingPeriod();

    /**
     * @notice Event emitted when a withdrawal is requested.
     * @param user The address of the user requesting the withdrawal.
     * @param token The address of the token to withdraw.
     * @param unbondingPeriod The unbonding period chosen for this withdrawal request.
     */
    event UnbondingRequested(
        address indexed user,
        address indexed token,
        uint64 unbondingPeriod
    );

    /**
     * @notice Event emitted when an unbonding period has passed and the withdrawal is authorized.
     * @param user The address of the user completing the withdrawal.
     * @param token The address of the token being withdrawn.
     */
    event UnbondingCompleted(address indexed user, address indexed token);

    /**
     * @notice Event emitted when an unbonding period's status is updated.
     * @param unbondingPeriod The unbonding period that was updated.
     * @param isSupported Whether the unbonding period is now supported.
     */
    event UnbondingPeriodStatusChanged(uint64 unbondingPeriod, bool isSupported);

    // Set of all supported unbonding periods
    EnumerableSet.UintSet internal _supportedUnbondingPeriods;

    // Mapping of user address to token address to withdrawal request
    mapping(address user => mapping(address token => UnbondingRequest request))
        internal _unbondingRequests;

    /**
     * @dev Constructor sets the initial owner of the contract and enables the provided unbonding periods.
     * @param owner The address of the owner.
     * @param supportedUnbondingPeriods Array of unbonding periods to be initially supported.
     */
    constructor(
        address owner,
        uint64[] memory supportedUnbondingPeriods
    ) Ownable(owner) {
        for (uint256 i = 0; i < supportedUnbondingPeriods.length; i++) {
            uint64 period = supportedUnbondingPeriods[i];
            require(period > 0, InvalidUnbondingPeriod());
            _supportedUnbondingPeriods.add(period);
            emit UnbondingPeriodStatusChanged(period, true);
        }
    }

    /**
     * @notice Checks if an unbonding period is supported.
     * @param unbondingPeriod The unbonding period to check.
     * @return True if the unbonding period is supported, false otherwise.
     */
    function isUnbondingPeriodSupported(
        uint64 unbondingPeriod
    ) external view returns (bool) {
        return _supportedUnbondingPeriods.contains(unbondingPeriod);
    }

    /**
     * @notice Get all supported unbonding periods.
     * @return An array of all supported unbonding periods.
     */
    function getAllSupportedUnbondingPeriods() external view returns (uint64[] memory) {
        uint256 totalPeriods = _supportedUnbondingPeriods.length();
        uint64[] memory result = new uint64[](totalPeriods);

        for (uint256 i = 0; i < totalPeriods; i++) {
            result[i] = uint64(_supportedUnbondingPeriods.at(i));
        }

        return result;
    }

    /**
     * @notice Get the withdrawal request details for a user and token.
     * @param user The address of the user.
     * @param token The address of the token.
     * @return requestTimestamp The timestamp when the withdrawal was requested.
     * @return unbondingPeriod The unbonding period chosen for this withdrawal request.
     */
    function getUnbondingRequest(
        address user,
        address token
    )
        external
        view
        returns (uint64 requestTimestamp, uint64 unbondingPeriod)
    {
        UnbondingRequest memory request = _unbondingRequests[user][token];
        return (
            request.requestTimestamp,
            request.unbondingPeriod
        );
    }

    /**
     * @notice Check if a user has an active unbonding request for a token.
     * @param user The address of the user.
     * @param token The address of the token.
     * @return True if the user has an active unbonding request, false otherwise.
     */
    function hasActiveUnbondingRequest(
        address user,
        address token
    ) external view returns (bool) {
        return _unbondingRequests[user][token].requestTimestamp != 0;
    }

    /**
     * @notice Check if a withdrawal is authorized.
     * @dev Returns true if the unbonding period has passed since the withdrawal request.
     *      As a side effect, this function deletes the unbonding request if authorized.
     * @param owner The address of the token owner.
     * @param token The address of the token.
     * @return True if the withdrawal is authorized, false otherwise.
     */
    function authorize(
        address owner,
        address token,
        uint256 // amount - not used
    ) external override returns (bool) {
        UnbondingRequest memory request = _unbondingRequests[owner][token];

        // Check if withdrawal was requested
        require(
            request.requestTimestamp != 0,
            UnbondingNotRequested(owner, token)
        );

        // Check if unbonding period has passed
        // Note: We don't check if the unbonding period is still supported
        require(
            uint64(block.timestamp) >=
                request.requestTimestamp + request.unbondingPeriod,
            UnbondingPeriodNotExpired(
                request.requestTimestamp,
                uint64(block.timestamp),
                request.unbondingPeriod
            )
        );

        // NOTE: this logic is put as side-effect as there is no other way to do it in the current Vault-Authorizer architecture
        // Remove the unbonding request
        delete _unbondingRequests[owner][token];
        emit UnbondingCompleted(owner, token);

        return true;
    }

    /**
     * @notice Updates the status of an unbonding period.
     * @param unbondingPeriod The unbonding period to update.
     * @param isSupported Whether the unbonding period should be supported.
     */
    function setUnbondingPeriodStatus(
        uint64 unbondingPeriod,
        bool isSupported
    ) external onlyOwner {
        require(unbondingPeriod > 0, InvalidUnbondingPeriod());

        if (isSupported) {
            _supportedUnbondingPeriods.add(unbondingPeriod);
        } else {
            _supportedUnbondingPeriods.remove(unbondingPeriod);
        }

        emit UnbondingPeriodStatusChanged(unbondingPeriod, isSupported);
    }

    /**
     * @notice Request a withdrawal for a specific token with a specific unbonding period.
     * @dev Emits a UnbondingRequested event.
     * @param token The address of the token to withdraw.
     * @param unbondingPeriod The unbonding period to use for this withdrawal request.
     */
    function requestUnbonding(
        address token,
        uint64 unbondingPeriod
    ) public {
        require(
            _supportedUnbondingPeriods.contains(unbondingPeriod),
            UnsupportedUnbondingPeriod(unbondingPeriod)
        );

        address account = msg.sender;
        _unbondingRequests[account][token] = UnbondingRequest({
            requestTimestamp: uint64(block.timestamp),
            unbondingPeriod: unbondingPeriod
        });

        emit UnbondingRequested(account, token, unbondingPeriod);
    }
}
