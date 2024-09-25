// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Test, Vm} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {IVoucher} from "../../src/interfaces/IVoucher.sol";
import {MockedVoucherExecutor} from "../../src/voucher/test/MockedVoucherExecutor.sol";
import {TestVoucherRouter} from "../../src/voucher/test/TestVoucherRouter.sol";
import {VoucherTestUtils} from "./VoucherTestUtils.sol";

contract VoucherRouterTestBase is VoucherTestUtils {
    TestVoucherRouter router;
    MockedVoucherExecutor executor;

    Vm.Wallet Owner = vm.createWallet("owner");
    Vm.Wallet DefaultIssuer = vm.createWallet("defaultIssuer");
    Vm.Wallet ExecutorIssuer = vm.createWallet("executorIssuer");
    Vm.Wallet Beneficiary = vm.createWallet("beneficiary");
    Vm.Wallet Someone = vm.createWallet("someone");
    Vm.Wallet Someother = vm.createWallet("someother");

    IVoucher.Voucher defaultVoucher;
    uint64 VOUCHER_LIFE_TIME = 5 * 60;

    constructor() VoucherTestUtils(VOUCHER_LIFE_TIME) {}

    function setUp() public virtual {
        router = new TestVoucherRouter(Owner.addr, DefaultIssuer.addr);
        executor = new MockedVoucherExecutor(address(router));
        defaultVoucher = IVoucher.Voucher({
            chainId: uint32(block.chainid),
            router: address(router),
            executor: address(executor),
            beneficiary: Beneficiary.addr,
            nonce: 0,
            expireAt: 0,
            data: "",
            signature: ""
        });

        defaultVoucher = renewVoucher(defaultVoucher);
    }
}

contract VoucherRouterTest is VoucherRouterTestBase {
    function test_constructor_defaultIssuerSet() public view {
        assertEq(router.defaultIssuer(), DefaultIssuer.addr, "Incorrect defaultIssuer");
    }
}

contract VoucherRouterTest_setDefaultIssuer is VoucherRouterTestBase {
    function test_success_ifOwner() public {
        vm.prank(Owner.addr);
        router.setDefaultIssuer(address(1));
        assertEq(router.defaultIssuer(), address(1), "Incorrect defaultIssuer");
    }

    function test_revert_ifNotOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, Someone.addr));
        vm.prank(Someone.addr);
        router.setDefaultIssuer(address(1));
    }

    function test_revert_ifIssuerZero() public {
        vm.expectRevert(abi.encodeWithSelector(IVoucher.InvalidIssuer.selector));
        vm.prank(Owner.addr);
        router.setDefaultIssuer(address(0));
    }
}

contract VoucherRouterTest_setExecutorIssuer is VoucherRouterTestBase {
    function test_success_ifOwner() public {
        vm.prank(Owner.addr);
        router.setExecutorIssuer(address(executor), address(1));
        assertEq(router.executorIssuers(address(executor)), address(1), "Incorrect executor issuer");
    }

    function test_revert_ifNotOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, Someone.addr));
        vm.prank(Someone.addr);
        router.setExecutorIssuer(address(executor), address(1));
    }
}

contract VoucherRouterTest_validateSignature is VoucherRouterTestBase {
    function test_valid_ifCorrectSignature_withDefaultIssuer() public view {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, DefaultIssuer);
        router.exposed_validateSignature(v);
    }

    function test_valid_ifCorrectSignature_withExecutorIssuer() public {
        router.workaround_setExecutorIssuer(address(executor), ExecutorIssuer.addr);
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, ExecutorIssuer);
        router.exposed_validateSignature(v);
    }

    function test_checkSkipped_ifExecutorIssuerSetTo1() public {
        router.workaround_setExecutorIssuer(address(executor), address(1));
        vm.assertEq(defaultVoucher.signature, "", "Signature not empty");
        router.exposed_validateSignature(defaultVoucher);
    }

    function test_revert_ifExecutorIssuerSet_signedWithDefaultIssuer() public {
        router.workaround_setExecutorIssuer(address(executor), ExecutorIssuer.addr);
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, DefaultIssuer);
        vm.expectRevert(abi.encodeWithSelector(IVoucher.InvalidSignature.selector));
        router.exposed_validateSignature(v);
    }

    function test_revert_ifExecutorIssuerNotSet_signedWithExecutorIssuer() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, ExecutorIssuer);
        vm.expectRevert(abi.encodeWithSelector(IVoucher.InvalidSignature.selector));
        router.exposed_validateSignature(v);
    }

    function test_revert_ifExecutorIssuerNotSet_signedWithRandom() public {
        IVoucher.Voucher memory v = signVoucher(defaultVoucher, Someone);
        vm.expectRevert(abi.encodeWithSelector(IVoucher.InvalidSignature.selector));
        router.exposed_validateSignature(v);
    }
}

contract VoucherRouterTest_validateVoucher is VoucherRouterTestBase {
    function test_valid_ifCorrectVoucher() public view {
        router.exposed_validateVoucher(defaultVoucher);
    }

    function test_revert_ifChainIdMismatch() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.chainId = 1;
        vm.expectRevert(abi.encodeWithSelector(IVoucher.InvalidChainId.selector));
        router.exposed_validateVoucher(v);
    }

    function test_revert_ifRouterMismatch() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.router = address(1);
        vm.expectRevert(abi.encodeWithSelector(IVoucher.InvalidRouter.selector));
        router.exposed_validateVoucher(v);
    }

    function test_revert_ifExecutorZero() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.executor = address(0);
        vm.expectRevert(abi.encodeWithSelector(IVoucher.InvalidExecutor.selector));
        router.exposed_validateVoucher(v);
    }

    function test_revert_ifVoucherExpired() public {
        IVoucher.Voucher memory v = defaultVoucher;
        v.expireAt = uint64(block.timestamp - 1);
        vm.expectRevert(abi.encodeWithSelector(IVoucher.VoucherExpired.selector));
        router.exposed_validateVoucher(v);
    }

    function test_revert_ifVoucherAlreadyUsed() public {
        IVoucher.Voucher memory v = defaultVoucher;
        router.workaround_setVoucherUsed(v.nonce, true);
        vm.expectRevert(abi.encodeWithSelector(IVoucher.VoucherAlreadyUsed.selector));
        router.exposed_validateVoucher(v);
    }
}

contract VoucherRouterTest_routeVoucher is VoucherRouterTestBase {
    function test_markAsUsed() public {
        IVoucher.Voucher memory v = defaultVoucher;
        router.exposed_routeVoucher(v);
        assertEq(router.usedVouchers(v.nonce), true, "Voucher not marked as used");
    }

    function test_executeCalledOnExecutor() public {
        vm.assertEq(executor.nonce(), 0, "executor nonce not 0");
        IVoucher.Voucher memory v = defaultVoucher;
        router.exposed_routeVoucher(v);
        assertEq(executor.nonce(), 1, "executor nonce not incremented");
    }
}
