// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IAuthorize.sol";

/**
 * @title TimeRangeAuthorizer
 * @dev Authorizer contract that allows actions only outside a specified time range.
 */
contract TimeRangeAuthorizer is IAuthorize {
    /**
     * @notice Error thrown when the start of the time range is greater than or equal to the end.
     * @param startTimestamp The start of the forbidden time range.
     * @param endTimestamp The end of the forbidden time range.
     */
    error InvalidTimeRange(uint256 startTimestamp, uint256 endTimestamp);

    uint256 public startTimestamp;
    uint256 public endTimestamp;

    /**
     * @dev Constructor sets the forbidden time range.
     * @param startTimestamp_ The start of the forbidden time range.
     * @param endTimestamp_ The end of the forbidden time range.
     */
    constructor(uint256 startTimestamp_, uint256 endTimestamp_) {
        if (startTimestamp_ >= endTimestamp_) {
            revert InvalidTimeRange(startTimestamp_, endTimestamp_);
        }

        startTimestamp = startTimestamp_;
        endTimestamp = endTimestamp_;
    }

    /**
     * @dev Authorizes actions only outside the specified time range.
     * @return True if the current time is outside the specified time range, false otherwise.
     */
    function authorize(address, address, uint256) external view override returns (bool) {
        return block.timestamp < startTimestamp || block.timestamp > endTimestamp;
    }
}
