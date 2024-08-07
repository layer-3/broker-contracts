// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IAuthorize.sol";

/**
 * @title TimeRangeAuthorizer
 * @dev Authorizer contract that allows actions only outside a specified time range.
 */
contract TimeRangeAuthorizer is IAuthorize {
    /**
     * @notice Emitted when the time range is updated.
     * @param newStartTimestamp The new start of the forbidden time range.
     * @param newEndTimestamp The new end of the forbidden time range.
     */
    event TimeRangeUpdated(uint256 newStartTimestamp, uint256 newEndTimestamp);

    /**
     * @notice Error thrown when the caller is not the owner of the contract.
     * @param account The caller of the function that is not the owner.
     */
    error NotOwner(address account);

    /**
     * @notice Error thrown when the start of the time range is greater than or equal to the end.
     * @param startTimestamp The start of the forbidden time range.
     * @param endTimestamp The end of the forbidden time range.
     */
    error InvalidTimeRange(uint256 startTimestamp, uint256 endTimestamp);

    address public immutable owner;
    uint256 public startTimestamp;
    uint256 public endTimestamp;

    /**
     * @dev Modifier to check if the caller is the owner of the contract.
     */
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    /**
     * @dev Constructor sets the initial owner and the forbidden time range.
     * @param startTimestamp_ The start of the forbidden time range.
     * @param endTimestamp_ The end of the forbidden time range.
     */
    constructor(
        address owner_,
        uint256 startTimestamp_,
        uint256 endTimestamp_
    ) {
        if (startTimestamp_ >= endTimestamp_)
            revert InvalidTimeRange(startTimestamp_, endTimestamp_);

        owner = owner_;
        startTimestamp = startTimestamp_;
        endTimestamp = endTimestamp_;
    }

    /**
     * @dev Authorizes actions only outside the specified time range.
     * @return True if the current time is outside the specified time range, false otherwise.
     */
    function authorize(
        address,
        address,
        uint256
    ) external view override returns (bool) {
        return
            block.timestamp < startTimestamp || block.timestamp > endTimestamp;
    }

    /**
     * @dev Updates the start and end timestamps of the forbidden time range.
     * @param newStartTimestamp The new start of the forbidden time range.
     * @param newEndTimestamp The new end of the forbidden time range.
     */
    function setTimeRange(
        uint256 newStartTimestamp,
        uint256 newEndTimestamp
    ) external onlyOwner {
        if (newStartTimestamp >= newEndTimestamp)
            revert InvalidTimeRange(newStartTimestamp, newEndTimestamp);

        startTimestamp = newStartTimestamp;
        endTimestamp = newEndTimestamp;
        emit TimeRangeUpdated(newStartTimestamp, newEndTimestamp);
    }
}
