// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAuthorize.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TimeRangeAuthorizer is IAuthorize, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 public startDate;
    uint256 public endDate;

    event AuthorizationUpdated(uint256 newStartDate, uint256 newEndDate);

    constructor(uint256 _startDate, uint256 _endDate) {
        require(_startDate < _endDate, "Start date must be before end date");
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        startDate = _startDate;
        endDate = _endDate;
    }

    function authorize(address, address, uint256) external view override returns (bool) {
        return block.timestamp < startDate || block.timestamp > endDate;
    }

    function resetDates(uint256 newStartDate, uint256 newEndDate) external onlyRole(ADMIN_ROLE) {
        require(newStartDate < newEndDate, "New start date must be before new end date");
        startDate = newStartDate;
        endDate = newEndDate;
        emit AuthorizationUpdated(newStartDate, newEndDate);
    }
}
