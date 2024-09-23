// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, Vm} from "forge-std/Test.sol";

import {LiteVault} from "../../src/vault/LiteVault.sol";
import {TestERC20} from "../TestERC20.sol";
import {IAuthorize} from "../../src/interfaces/IAuthorize.sol";
import {TrueAuthorize, FalseAuthorize} from "./MockedAuthorizer.sol";

uint256 constant TIME = 1716051867;

contract LiteVaultTest_integration is Test {
    TrueAuthorize trueAuth;
    FalseAuthorize falseAuth;
    LiteVault vault;
    TestERC20 token;

    address owner = vm.createWallet("owner").addr;
    address user = vm.createWallet("user").addr;

    uint64 public constant WITHDRAWAL_GRACE_PERIOD = 3 days;

    uint256 public constant ETH_DEP_AMOUNT = 42e5;
    uint256 public constant ERC20_DEP_AMOUNT = 420e6;

    function setUp() public {
        trueAuth = new TrueAuthorize();
        falseAuth = new FalseAuthorize();
        vault = new LiteVault(owner, trueAuth);
        token = new TestERC20("Test", "TST", 1, type(uint256).max);

        vm.deal(user, ETH_DEP_AMOUNT);
        token.mint(address(user), ERC20_DEP_AMOUNT);

        vm.warp(TIME);
    }

    function test_ERC20Flow() public {
        // Deposit
        vm.startPrank(user);
        token.approve(address(vault), ERC20_DEP_AMOUNT);
        vault.deposit(address(token), ERC20_DEP_AMOUNT);
        vm.stopPrank();

        assertEq(token.balanceOf(user), 0, "user balance not empty");
        assertEq(token.balanceOf(address(vault)), ERC20_DEP_AMOUNT, "vault balance not equal to deposit");
        assertEq(vault.balanceOf(user, address(token)), ERC20_DEP_AMOUNT, "user balance on vault not equal to deposit");

        vm.warp(TIME + 5 days);

        // Withdraw
        vm.prank(user);
        vault.withdraw(address(token), ERC20_DEP_AMOUNT);

        assertEq(token.balanceOf(user), ERC20_DEP_AMOUNT, "user balance not equal to deposit");
        assertEq(token.balanceOf(address(vault)), 0, "vault balance not empty");
        assertEq(vault.balanceOf(user, address(token)), 0, "user balance on vault not empty");
    }

    function test_ETHFlow() public {
        // Deposit
        vm.prank(user);
        vault.deposit{value: ETH_DEP_AMOUNT}(address(0), ETH_DEP_AMOUNT);

        assertEq(user.balance, 0, "user balance not empty");
        assertEq(address(vault).balance, ETH_DEP_AMOUNT, "vault balance not equal to deposit");
        assertEq(vault.balanceOf(user, address(0)), ETH_DEP_AMOUNT, "user balance on vault not equal to deposit");

        vm.warp(TIME + 5 days);

        // Withdraw
        vm.prank(user);
        vault.withdraw(address(0), ETH_DEP_AMOUNT);

        assertEq(user.balance, ETH_DEP_AMOUNT, "user balance not equal to deposit");
        assertEq(address(vault).balance, 0, "vault balance not empty");
        assertEq(vault.balanceOf(user, address(0)), 0, "user balance on vault not empty");
    }

    function test_gracePeriodFlow() public {
        FalseAuthorize newAuthorizer = new FalseAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(newAuthorizer);

        uint256 time = TIME + WITHDRAWAL_GRACE_PERIOD;
        vm.warp(time);

        uint256 withdraw1Amount = 42e4;
        uint256 withdraw2Amount = 1e4;

        // Deposit tokens
        vm.startPrank(user);
        token.approve(address(vault), ERC20_DEP_AMOUNT);
        vault.deposit(address(token), ERC20_DEP_AMOUNT);
        vm.stopPrank();

        time += 1 days;
        vm.warp(time);

        // Revert on withdraw
        vm.expectRevert(abi.encodeWithSelector(IAuthorize.Unauthorized.selector, user, address(token), withdraw1Amount));
        vm.prank(user);
        vault.withdraw(address(token), withdraw1Amount);

        // Change authorizer
        newAuthorizer = new FalseAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(newAuthorizer);

        time += 1 days;
        vm.warp(time);

        // Withdraw tokens
        vm.prank(user);
        vault.withdraw(address(token), withdraw1Amount);
        assertEq(token.balanceOf(user), withdraw1Amount, "user balance not equal to withdraw");
        assertEq(
            vault.balanceOf(user, address(token)),
            ERC20_DEP_AMOUNT - withdraw1Amount,
            "user balance on vault not equal to deposit - withdraw"
        );

        // Grace period has ended
        time += WITHDRAWAL_GRACE_PERIOD;
        vm.warp(time);

        // Revert on withdraw
        vm.expectRevert(abi.encodeWithSelector(IAuthorize.Unauthorized.selector, user, address(token), withdraw2Amount));
        vm.prank(user);
        vault.withdraw(address(token), withdraw2Amount);
    }
}
