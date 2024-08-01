// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IAuthorize.sol";

contract MockAuthorize is IAuthorize {
    function authorize(address, address, uint256) external pure override returns (bool) {
        return true;
    }
}
