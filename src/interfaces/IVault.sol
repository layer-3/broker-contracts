// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVault {
    function deposit(address token, uint256 amount) external payable;
    function withdraw(address token, uint256 amount) external;
    function balanceOf(address user, address token) external view returns (uint256);
}
