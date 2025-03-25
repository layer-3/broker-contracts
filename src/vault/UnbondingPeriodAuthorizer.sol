// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IAuthorize} from "../interfaces/IAuthorize.sol";

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
     * @notice Error thrown when the unbonding period has not yet passed.
     * @param requestTimestamp The timestamp when the withdrawal was requested.
     * @param currentTimestamp The current timestamp.
     * @param unbondingPeriod The required unbonding period.
     */
    error UnbondingPeriodNotExpired(uint64 requestTimestamp, uint64 currentTimestamp, uint64 unbondingPeriod);

    /**
     * @notice Error thrown when the withdrawal has already been requested.
     * @param user The address of the user.
     * @param token The address of the token.
     */
    error UnbondingAlreadyRequested(address user, address token);

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
     * @param unbondingTimestamp The timestamp when the unbonding period will expire.
     */
    event UnbondingRequested(
        address indexed user, address indexed token, uint64 unbondingPeriod, uint64 unbondingTimestamp
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

    /**
     * @notice Struct to store withdrawal request information.
     * @param requestTimestamp The timestamp when the withdrawal was requested.
     * @param unbondingPeriod The unbonding period chosen for this withdrawal request.
     */
    struct UnbondingRequest {
        uint64 requestTimestamp;
        uint64 unbondingPeriod;
    }

    // Set of all supported unbonding periods
    EnumerableSet.UintSet internal _supportedUnbondingPeriods;

    // Mapping of user address to token address to withdrawal request
    mapping(address user => mapping(address token => UnbondingRequest request)) internal _unbondingRequests;

    /**
     * @dev Constructor sets the initial owner of the contract and enables the provided unbonding periods.
     * @param owner The address of the owner.
     * @param supportedUnbondingPeriods Array of unbonding periods to be initially supported.
     */
    constructor(address owner, uint64[] memory supportedUnbondingPeriods) Ownable(owner) {
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
    function isUnbondingPeriodSupported(uint64 unbondingPeriod) external view returns (bool) {
        return _supportedUnbondingPeriods.contains(unbondingPeriod);
    }

    /**
     * @notice Get all supported unbonding periods.
     * @return An array of all supported unbonding periods.
     */
    function getAllSupportedUnbondingPeriods() external view returns (uint256[] memory) {
        return _supportedUnbondingPeriods.values();
    }

    /**
     * @notice Get the withdrawal request details for a user and token.
     * @param user The address of the user.
     * @param token The address of the token.
     * @return requestTimestamp The timestamp when the withdrawal was requested.
     * @return unbondingPeriod The unbonding period chosen for this withdrawal request.
     */
    function getUnbondingRequest(address user, address token)
        external
        view
        returns (uint64 requestTimestamp, uint64 unbondingPeriod)
    {
        UnbondingRequest memory request = _unbondingRequests[user][token];
        return (request.requestTimestamp, request.unbondingPeriod);
    }

    /**
     * @notice Check if a user has an active unbonding request for a token.
     * @param user The address of the user.
     * @param token The address of the token.
     * @return True if the user has an active unbonding request, false otherwise.
     */
    function hasActiveUnbondingRequest(address user, address token) external view returns (bool) {
        return _unbondingRequests[user][token].requestTimestamp != 0;
    }

    /**
     * @notice Check if a withdrawal is authorized.
     * @dev Returns true if the unbonding period has passed since the withdrawal request.
     * @param owner The address of the token owner.
     * @param token The address of the token.
     * @return True if the withdrawal is authorized, false otherwise.
     */
    function authorize(
        address owner,
        address token,
        uint256 // amount - not used
    ) public view returns (bool) {
        UnbondingRequest memory request = _unbondingRequests[owner][token];

        // Check if withdrawal was requested
        require(request.requestTimestamp != 0, UnbondingNotRequested(owner, token));

        // Check if unbonding period has passed
        // Note: We don't check if the unbonding period is still supported
        require(
            uint64(block.timestamp) >= request.requestTimestamp + request.unbondingPeriod,
            UnbondingPeriodNotExpired(request.requestTimestamp, uint64(block.timestamp), request.unbondingPeriod)
        );

        return true;
    }

    /**
     * @notice Updates the status of an unbonding period.
     * @param unbondingPeriod The unbonding period to update.
     * @param isSupported Whether the unbonding period should be supported.
     */
    function setUnbondingPeriodStatus(uint64 unbondingPeriod, bool isSupported) external onlyOwner {
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
    function requestUnbonding(address token, uint64 unbondingPeriod) public {
        require(_supportedUnbondingPeriods.contains(unbondingPeriod), UnsupportedUnbondingPeriod(unbondingPeriod));

        require(
            _unbondingRequests[msg.sender][token].requestTimestamp == 0, UnbondingAlreadyRequested(msg.sender, token)
        );

        address account = msg.sender;
        _unbondingRequests[account][token] =
            UnbondingRequest({requestTimestamp: uint64(block.timestamp), unbondingPeriod: unbondingPeriod});

        emit UnbondingRequested(account, token, unbondingPeriod, uint64(block.timestamp) + unbondingPeriod);
    }

    /**
     * @notice Completes an unbonding request after the unbonding period has passed.
     * @dev Verifies the unbonding period has passed before completing the request.
     *      It cleans up the request state and emits the UnbondingCompleted event.
     * @param token The address of the token for which to complete the unbonding request.
     */
    function completeUnbondingRequest(address token) external {
        _completeUnbondingRequest(msg.sender, token);
    }

    /**
     * @notice Completes multiple unbonding requests in a single transaction after their unbonding periods have passed.
     * @dev Verifies the unbonding period has passed for each token before completing the request.
     *      Will revert if any of the requests is not authorized (unbonding period not passed).
     * @param tokens Array of token addresses for which to complete unbonding requests.
     */
    function completeUnbondingRequests(address[] calldata tokens) external {
        address account = msg.sender;
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            _completeUnbondingRequest(account, token);
        }
    }

    /**
     * @dev Internal helper function to complete an unbonding request for a specific user and token.
     * It verifies the unbonding period has passed, deletes the request from storage and emits the UnbondingCompleted event.
     * @param account The address of the user who made the unbonding request.
     * @param token The address of the token for which to complete the unbonding request.
     */
    function _completeUnbondingRequest(address account, address token) internal {
        // Verify the unbonding period has passed
        // NOTE: authorization amount does not matter here
        authorize(account, token, 0);
        delete _unbondingRequests[account][token];
        emit UnbondingCompleted(account, token);
    }
}
