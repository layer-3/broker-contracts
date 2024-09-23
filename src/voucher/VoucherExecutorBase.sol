// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IVoucherExecutor} from "../interfaces/IVoucherExecutor.sol";

abstract contract VoucherExecutorBase is IVoucherExecutor, ReentrancyGuard {
    address public router;

    constructor(address router_) {
        router = router_;
    }

    function execute(address beneficiary, bytes calldata data) external nonReentrant {
        if (msg.sender != router) revert IVoucherExecutor.CallerIsNotRouter();
        _execute(beneficiary, data);
        emit Executed(beneficiary, data);
    }

    /// @dev Override this function to implement voucher execution logic
    function _execute(address, bytes calldata) internal virtual;
}
