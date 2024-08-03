// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAuthorize.sol";

/**
 * @title TimeRangeAuthorizer
 * @dev Authorizer contract that allows actions only within a specified time range.
 */
contract TimeRangeAuthorizer is IAuthorize {
    address public owner;
    uint256 public startTimestamp;
    uint256 public endTimestamp;

    event TimeRangeUpdated(uint256 newStartTimestamp, uint256 newEndTimestamp);

    /**
     * @dev Modifier to check if the caller is the owner of the contract.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    /**
     * @dev Constructor sets the initial owner and the time range.
     * @param _startTimestamp The start of the allowed time range.
     * @param _endTimestamp The end of the allowed time range.
     */
    constructor(uint256 _startTimestamp, uint256 _endTimestamp) {
        require(_startTimestamp < _endTimestamp, "Start timestamp must be before end timestamp");
        owner = msg.sender;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
    }

    /**
     * @dev Authorizes actions only outside the specified time range.
     * @return True if the current time is outside the specified time range, false otherwise.
     */
    function authorize(address, address, uint256) external view override returns (bool) {
        return block.timestamp < startTimestamp || block.timestamp > endTimestamp;
    }

    /**
     * @dev Updates the start and end timestamps of the allowed time range.
     * @param newStartTimestamp The new start of the allowed time range.
     * @param newEndTimestamp The new end of the allowed time range.
     */
    function setTimeRange(uint256 newStartTimestamp, uint256 newEndTimestamp) external onlyOwner {
        require(newStartTimestamp < newEndTimestamp, "New start timestamp must be before new end timestamp");
        startTimestamp = newStartTimestamp;
        endTimestamp = newEndTimestamp;
        emit TimeRangeUpdated(newStartTimestamp, newEndTimestamp);
    }
}
