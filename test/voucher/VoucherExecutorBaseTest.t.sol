// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, Vm} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {IVoucherExecutor} from "../../src/interfaces/IVoucherExecutor.sol";
import {MockedVoucherExecutor} from "../../src/voucher/test/MockedVoucherExecutor.sol";

contract VoucherExecutorBaseTest is Test {
    MockedVoucherExecutor executor;

    address router = vm.createWallet("router").addr;
    address beneficiary = vm.createWallet("beneficiary").addr;

    constructor() {
        executor = new MockedVoucherExecutor(router);
    }

    function test_success_executeIsCalled() public {
        assertEq(executor.nonce(), 0, "Incorrect nonce");
        vm.prank(router);
        executor.execute(beneficiary, "");
        assertEq(executor.nonce(), 1, "Incorrect nonce");
    }

    function test_eventEmitted() public {
        vm.expectEmit(true, true, true, true, address(executor));
        emit IVoucherExecutor.Executed(beneficiary, "");
        vm.prank(router);
        executor.execute(beneficiary, "");
    }

    function test_revert_ifCallerNotRouter() public {
        vm.expectRevert(IVoucherExecutor.CallerIsNotRouter.selector);
        vm.prank(beneficiary);
        executor.execute(beneficiary, "");
    }
}
