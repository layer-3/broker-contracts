// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VoucherExecutorBase} from "../VoucherExecutorBase.sol";

contract DummyExecutor is VoucherExecutorBase {
    constructor(address router) VoucherExecutorBase(router) {}

    function _execute(address, bytes calldata) internal override {
        // do nothing
    }
}
