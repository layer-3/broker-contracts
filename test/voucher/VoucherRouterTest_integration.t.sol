// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {Test, Vm} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {IVoucher} from "../../src/interfaces/IVoucher.sol";
import {VoucherRouterTestBase} from "./VoucherRouterTest.t.sol";

contract VoucherRouterTest_integration_use_noVouchers is VoucherRouterTestBase {
    IVoucher.Voucher[] vouchers;

    function test_revert_ifNoVouchers() public {
        vm.expectRevert(IVoucher.InvalidVouchersLength.selector);
        router.use(vouchers);
    }
}

contract VoucherRouterTest_integration_use_singleVoucher_defaultIssuer is VoucherRouterTestBase {
    IVoucher.Voucher[] vouchers;

    function test_success_ifValidVoucher() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, DefaultIssuer);
        vouchers.push(v);
        router.use(vouchers);
    }

    function test_callExecutor() public {
        assertEq(executor.nonce(), 0, "Incorrect nonce");
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, DefaultIssuer);
        vouchers.push(v);
        router.use(vouchers);
        assertEq(executor.nonce(), 1, "Incorrect nonce");
    }

    function test_emitEvent() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, DefaultIssuer);
        vouchers.push(v);
        vm.expectEmit(true, true, true, true, address(router));
        emit IVoucher.Used(vouchers[0]);
        router.use(vouchers);
    }

    function test_revert_ifSignedWithRandom() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, Someone);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidSignature.selector);
        router.use(vouchers);
    }

    function test_revert_ifSignedWithExecutorIssuer() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, ExecutorIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidSignature.selector);
        router.use(vouchers);
    }

    function test_revert_ifIncorrectChainId() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.chainId = 1;
        v = signVoucher(v, DefaultIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidChainId.selector);
        router.use(vouchers);
    }

    function test_revert_ifIncorrectRouter() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.router = address(1);
        v = signVoucher(v, DefaultIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidRouter.selector);
        router.use(vouchers);
    }

    function test_revert_ifExecutorZero() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.executor = address(0);
        v = signVoucher(v, DefaultIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidExecutor.selector);
        router.use(vouchers);
    }

    function test_revert_ifVoucherExpired() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.expireAt = uint64(block.timestamp - 1);
        v = signVoucher(v, DefaultIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.VoucherExpired.selector);
        router.use(vouchers);
    }

    function test_revert_ifReplay() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, DefaultIssuer);
        vouchers.push(v);
        router.use(vouchers);
        vm.expectRevert(IVoucher.VoucherAlreadyUsed.selector);
        router.use(vouchers);
    }
}

contract VoucherRouterTest_integration_use_singleVoucher_executorIssuer is VoucherRouterTestBase {
    IVoucher.Voucher[] vouchers;

    function setUp() public override {
        super.setUp();
        router.workaround_setExecutorIssuer(address(executor), ExecutorIssuer.addr);
    }

    function test_success_ifValidVoucher() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, ExecutorIssuer);
        vouchers.push(v);
        router.use(vouchers);
    }

    function test_callExecutor() public {
        assertEq(executor.nonce(), 0, "Incorrect nonce");
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, ExecutorIssuer);
        vouchers.push(v);
        router.use(vouchers);
        assertEq(executor.nonce(), 1, "Incorrect nonce");
    }

    function test_emitEvent() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, ExecutorIssuer);
        vouchers.push(v);
        vm.expectEmit(true, true, true, true, address(router));
        emit IVoucher.Used(vouchers[0]);
        router.use(vouchers);
    }

    function test_revert_ifSignedWithRandom() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, Someone);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidSignature.selector);
        router.use(vouchers);
    }

    function test_revert_ifSignedWithDefaultIssuer() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, DefaultIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidSignature.selector);
        router.use(vouchers);
    }

    function test_revert_ifIncorrectChainId() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.chainId = 1;
        v = signVoucher(v, ExecutorIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidChainId.selector);
        router.use(vouchers);
    }

    function test_revert_ifIncorrectRouter() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.router = address(1);
        v = signVoucher(v, ExecutorIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidRouter.selector);
        router.use(vouchers);
    }

    function test_revert_ifExecutorZero_signedByExecutorIssuer() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.executor = address(0);
        v = signVoucher(v, ExecutorIssuer);
        vouchers.push(v);
        // Invalid signature error as ExecutorIssuer is not set for address(0)
        vm.expectRevert(IVoucher.InvalidSignature.selector);
        router.use(vouchers);
    }

    function test_revert_ifExecutorZero_signedByDefaultIssuer() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.executor = address(0);
        // sign with DefaultIssuer so that the first error is overcome
        v = signVoucher(v, DefaultIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidExecutor.selector);
        router.use(vouchers);
    }

    function test_revert_ifVoucherExpired() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.expireAt = uint64(block.timestamp - 1);
        v = signVoucher(v, ExecutorIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.VoucherExpired.selector);
        router.use(vouchers);
    }

    function test_revert_ifReplay() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, ExecutorIssuer);
        vouchers.push(v);
        router.use(vouchers);
        vm.expectRevert(IVoucher.VoucherAlreadyUsed.selector);
        router.use(vouchers);
    }
}

contract VoucherRouterTest_integration_use_singleVoucher_addressOneIssuer is VoucherRouterTestBase {
    IVoucher.Voucher[] vouchers;

    function setUp() public override {
        super.setUp();
        router.workaround_setExecutorIssuer(address(executor), address(1));
    }

    function test_success_ifValidVoucher() public {
        vouchers.push(defaultVoucher);
        router.use(vouchers);
    }

    function test_callExecutor() public {
        assertEq(executor.nonce(), 0, "Incorrect nonce");
        vouchers.push(defaultVoucher);
        router.use(vouchers);
        assertEq(executor.nonce(), 1, "Incorrect nonce");
    }

    function test_emitEvent() public {
        vouchers.push(defaultVoucher);
        vm.expectEmit(true, true, true, true, address(router));
        emit IVoucher.Used(vouchers[0]);
        router.use(vouchers);
    }

    function test_success_ifSignedWithRandom() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, Someone);
        vouchers.push(v);
        router.use(vouchers);
    }

    function test_success_ifSignedWithDefaultIssuer() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, DefaultIssuer);
        vouchers.push(v);
        router.use(vouchers);
    }

    function test_revert_ifIncorrectChainId() public {
        defaultVoucher.chainId = 1;
        vouchers.push(defaultVoucher);
        vm.expectRevert(IVoucher.InvalidChainId.selector);
        router.use(vouchers);
    }

    function test_revert_ifIncorrectRouter() public {
        defaultVoucher.router = address(1);
        vouchers.push(defaultVoucher);
        vm.expectRevert(IVoucher.InvalidRouter.selector);
        router.use(vouchers);
    }

    function test_revert_ifExecutorZero_noSignature() public {
        defaultVoucher.executor = address(0);
        vouchers.push(defaultVoucher);
        // as address(0) does not have an issuer set, the signature is validated. It is not provided, therefore this error
        vm.expectRevert(abi.encodeWithSelector(ECDSA.ECDSAInvalidSignatureLength.selector, 0));
        router.use(vouchers);
    }

    function test_revert_ifExecutorZero_signedByDefaultIssuer() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.executor = address(0);
        // sign with DefaultIssuer so that the first error is overcome
        v = signVoucher(v, DefaultIssuer);
        vouchers.push(v);
        vm.expectRevert(IVoucher.InvalidExecutor.selector);
        router.use(vouchers);
    }

    function test_revert_ifVoucherExpired() public {
        defaultVoucher.expireAt = uint64(block.timestamp - 1);
        vouchers.push(defaultVoucher);
        vm.expectRevert(IVoucher.VoucherExpired.selector);
        router.use(vouchers);
    }

    function test_revert_ifReplay() public {
        vouchers.push(defaultVoucher);
        router.use(vouchers);
        vm.expectRevert(IVoucher.VoucherAlreadyUsed.selector);
        router.use(vouchers);
    }
}

contract VoucherRouterTest_integration_use_multipleVouchers_defaultIssuer is VoucherRouterTestBase {
    IVoucher.Voucher[] vouchers;

    function test_success_ifValidVouchers() public {
        IVoucher.Voucher memory v1 = signVoucher(defaultVoucher, DefaultIssuer);
        IVoucher.Voucher memory v2 = signVoucher(renewVoucher(defaultVoucher), DefaultIssuer);
        vouchers.push(v1);
        vouchers.push(v2);
        router.use(vouchers);
    }

    function test_callExecutor() public {
        assertEq(executor.nonce(), 0, "Incorrect nonce");
        IVoucher.Voucher memory v1 = signVoucher(defaultVoucher, DefaultIssuer);
        IVoucher.Voucher memory v2 = signVoucher(renewVoucher(defaultVoucher), DefaultIssuer);
        vouchers.push(v1);
        vouchers.push(v2);
        router.use(vouchers);
        assertEq(executor.nonce(), 2, "Incorrect nonce");
    }

    function test_emitEvents() public {
        IVoucher.Voucher memory v1 = signVoucher(defaultVoucher, DefaultIssuer);
        IVoucher.Voucher memory v2 = signVoucher(renewVoucher(defaultVoucher), DefaultIssuer);
        vouchers.push(v1);
        vouchers.push(v2);
        vm.expectEmit(true, true, true, true, address(router));
        emit IVoucher.Used(vouchers[0]);
        emit IVoucher.Used(vouchers[1]);
        router.use(vouchers);
    }

    // TODO: add revert tests
}
