// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAuthorize.sol";

contract TimeRangeAuthorizer is IAuthorize {
    address public owner;
    uint256 public startTimestamp;
    uint256 public endTimestamp;

    event TimeRangeUpdated(uint256 newStartTimestamp, uint256 newEndTimestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(uint256 _startTimestamp, uint256 _endTimestamp) {
        require(_startTimestamp < _endTimestamp, "Start timestamp must be before end timestamp");
        owner = msg.sender;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
    }

    function authorize(address, address, uint256) external view override returns (bool) {
        return block.timestamp < startTimestamp || block.timestamp > endTimestamp;
    }

    function setTimeRange(uint256 newStartTimestamp, uint256 newEndTimestamp) external onlyOwner {
        require(newStartTimestamp < newEndTimestamp, "New start timestamp must be before new end timestamp");
        startTimestamp = newStartTimestamp;
        endTimestamp = newEndTimestamp;
        emit TimeRangeUpdated(newStartTimestamp, newEndTimestamp);
    }
}
