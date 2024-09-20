// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IAuthorize} from "../../src/interfaces/IAuthorize.sol";

contract TrueAuthorize is IAuthorize {
    function authorize(address, address, uint256) external pure override returns (bool) {
        return true;
    }
}

contract FalseAuthorize is IAuthorize {
    function authorize(address, address, uint256) external pure override returns (bool) {
        return false;
    }
}
