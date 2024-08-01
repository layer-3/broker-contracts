// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthorize {
    function authorize(address owner, address token, uint256 amount) external view returns (bool);
}
