// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAuthorize.sol";

contract TimeRangeAuthorizer is IAuthorize {
    address public owner;
    uint256 public startDate;
    uint256 public endDate;

    event AuthorizationUpdated(uint256 newEndDate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(uint256 _startDate, uint256 _endDate) {
        require(_startDate < _endDate, "Start date must be before end date");
        owner = msg.sender;
        startDate = _startDate;
        endDate = _endDate;
    }

    function authorize(address owner, address token, uint256 amount) external view override returns (bool) {
        return block.timestamp < startDate || block.timestamp > endDate;
    }

    function resetEndDate(uint256 newEndDate) external onlyOwner {
        require(newEndDate > startDate, "New end date must be after start date");
        endDate = newEndDate;
        emit AuthorizationUpdated(newEndDate);
    }
}
