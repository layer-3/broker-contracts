// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VoucherExecutorBase} from "../VoucherExecutorBase.sol";

contract MockedVoucherExecutor is VoucherExecutorBase {
    uint256 public nonce;

    constructor(address router_) VoucherExecutorBase(router_) {}

    function _execute(address, bytes calldata) internal override {
        nonce++;
    }
}
