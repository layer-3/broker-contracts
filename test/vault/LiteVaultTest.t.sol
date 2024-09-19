// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/Test.sol";

import {CostlyReceiver} from "./CostlyReceiver.sol";
import {TestLiteVault} from "../../src/vault/test/TestLiteVault.sol";
import "../../src/interfaces/IVault.sol";
import "../../src/interfaces/IAuthorize.sol";
import {IAuthorizable} from "../../src/interfaces/IAuthorizable.sol";
import "./MockedAuthorizer.sol";
import "../TestERC20.sol";

uint256 constant TIME = 1716051867;

contract LiteVaultTest is Test {
    TestLiteVault vault;
    TestERC20 token1;
    TestERC20 token2;
    TrueAuthorize trueAuthorizer;

    address deployer = vm.createWallet("deployer").addr;
    address owner = vm.createWallet("owner").addr;
    address someone = vm.createWallet("someone").addr;

    uint64 public constant WITHDRAWAL_GRACE_PERIOD = 3 days;

    uint256 ethBalance = 1 ether;
    uint256 token1Balance = 42e6;

    function setUp() public {
        trueAuthorizer = new TrueAuthorize();
        vm.prank(deployer);
        vault = new TestLiteVault(owner, trueAuthorizer);
        // warp to fhe future so that grace period is not active
        vm.warp(TIME);

        token1 = new TestERC20("Test1", "TST1", 18, type(uint256).max);
        token2 = new TestERC20("Test2", "TST2", 18, type(uint256).max);
        token1.mint(address(vault), token1Balance);
        vm.deal(address(vault), ethBalance);
    }

    function test_constructor() public view {
        assertEq(vault.owner(), owner);
        assertEq(address(vault.authorizer()), address(trueAuthorizer));
    }

    function test_constructor_revert_ifInvalidAuthorizerAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IVault.InvalidAddress.selector));
        new TestLiteVault(owner, IAuthorize(address(0)));
    }

    function test_balanceOf() public {
        // zero balances at start
        assertEq(vault.balanceOf(address(vault), address(0)), 0);
        assertEq(vault.balanceOf(address(vault), address(token1)), 0);
        assertEq(vault.balanceOf(address(vault), address(token2)), 0);

        // deposit ETH
        uint256 ethAmount = 42e5;
        vm.deal(someone, ethAmount);
        vm.prank(someone);
        vault.deposit{value: ethAmount}(address(0), ethAmount);
        assertEq(vault.balanceOf(someone, address(0)), ethAmount);

        // deposit token1
        uint256 token1Amount = 32e5;
        token1.mint(someone, token1Amount);
        vm.startPrank(someone);
        token1.approve(address(vault), type(uint256).max);
        vault.deposit(address(token1), token1Amount);
        vm.stopPrank();
        assertEq(vault.balanceOf(someone, address(token1)), token1Amount);

        // deposit token2
        uint256 token2Amount = 22e5;
        token2.mint(someone, token2Amount);
        vm.startPrank(someone);
        token2.approve(address(vault), type(uint256).max);
        vault.deposit(address(token2), token2Amount);
        vm.stopPrank();
        assertEq(vault.balanceOf(someone, address(token2)), token2Amount);
    }

    function test_balancesOfTokens() public {
        // zero balances at start
        assertEq(vault.balancesOfTokens(address(vault), new address[](0)).length, 0);

        // deposit ETH
        uint256 ethAmount = 42e5;
        vm.deal(someone, ethAmount);
        vm.prank(someone);
        vault.deposit{value: ethAmount}(address(0), ethAmount);
        address[] memory tokens = new address[](3);
        tokens[0] = address(0);
        tokens[1] = address(token1);
        tokens[2] = address(token2);
        uint256[] memory balances = vault.balancesOfTokens(someone, tokens);
        assertEq(balances.length, 3);
        assertEq(balances[0], ethAmount);
        assertEq(balances[1], 0);
        assertEq(balances[2], 0);

        // deposit token1
        uint256 token1Amount = 52e5;
        token1.mint(someone, token1Amount);
        vm.startPrank(someone);
        token1.approve(address(vault), type(uint256).max);
        vault.deposit(address(token1), token1Amount);
        vm.stopPrank();
        balances = vault.balancesOfTokens(someone, tokens);
        assertEq(balances.length, 3);
        assertEq(balances[0], ethAmount);
        assertEq(balances[1], token1Amount);
        assertEq(balances[2], 0);

        // deposit token2
        uint256 token2Amount = 62e5;
        token2.mint(someone, token2Amount);
        vm.startPrank(someone);
        token2.approve(address(vault), type(uint256).max);
        vault.deposit(address(token2), token2Amount);
        vm.stopPrank();
        balances = vault.balancesOfTokens(someone, tokens);
        assertEq(balances.length, 3);
        assertEq(balances[0], ethAmount);
        assertEq(balances[1], token1Amount);
        assertEq(balances[2], token2Amount);
    }

    function test_isWithdrawGracePeriodActive() public view {
        uint64 now_ = 1716051867;

        // Grace period is active

        uint64 latestSetAuthorizerTimestamp = now_ - 2 days;
        assert(vault.exposed_isWithdrawalGracePeriodActive(latestSetAuthorizerTimestamp, now_, WITHDRAWAL_GRACE_PERIOD));

        latestSetAuthorizerTimestamp = now_ - 2 days - 23 hours;
        assert(vault.exposed_isWithdrawalGracePeriodActive(latestSetAuthorizerTimestamp, now_, WITHDRAWAL_GRACE_PERIOD));

        // Grace period is not active

        latestSetAuthorizerTimestamp = now_ - 3 days - 1 minutes;
        assert(
            !vault.exposed_isWithdrawalGracePeriodActive(latestSetAuthorizerTimestamp, now_, WITHDRAWAL_GRACE_PERIOD)
        );

        latestSetAuthorizerTimestamp = now_ - 4 days;
        assert(
            !vault.exposed_isWithdrawalGracePeriodActive(latestSetAuthorizerTimestamp, now_, WITHDRAWAL_GRACE_PERIOD)
        );
    }

    function test_successSetAuthorizerIfOwner() public {
        TrueAuthorize newAuthorizer = new TrueAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(newAuthorizer);
        assertEq(address(vault.authorizer()), address(newAuthorizer));
    }

    function test_updateSetAuthTimestamp_ifAuthSet() public {
        TrueAuthorize newAuthorizer = new TrueAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(newAuthorizer);
        assertEq(vault.latestSetAuthorizerTimestamp(), block.timestamp);
    }

    function test_revertSetAuthorizerIfNotOwner() public {
        FalseAuthorize newAuthorizer = new FalseAuthorize();
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, someone));
        vm.prank(someone);
        vault.setAuthorizer(newAuthorizer);
    }

    function test_revertSetAuthorizerIfAuthorizerZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IVault.InvalidAddress.selector));
        vm.prank(owner);
        vault.setAuthorizer(IAuthorize(address(0)));
    }

    function test_setAuthorizer_emitEvent() public {
        TrueAuthorize newAuthorizer = new TrueAuthorize();
        vm.expectEmit(true, true, true, true);
        emit IAuthorizable.AuthorizerChanged(newAuthorizer);
        vm.prank(owner);
        vault.setAuthorizer(newAuthorizer);
    }

    function test_depositSuccessEth() public {
        uint256 amount = 42e5;
        vm.deal(someone, amount);

        vm.prank(someone);
        vault.deposit{value: amount}(address(0), amount);
        assertEq(address(vault).balance, ethBalance + amount);
        assertEq(someone.balance, 0);
    }

    function test_depositSuccessERC20() public {
        uint256 amount = 42e5;
        token1.mint(someone, amount);

        vm.prank(someone);
        token1.approve(address(vault), type(uint256).max);
        vm.prank(someone);
        vault.deposit(address(token1), amount);
        assertEq(token1.balanceOf(address(vault)), token1Balance + amount);
        assertEq(token1.balanceOf(someone), 0);
    }

    function test_depositRevertIfEthNoMsgValue() public {
        vm.expectRevert(abi.encodeWithSelector(IVault.IncorrectValue.selector));
        vm.prank(someone);
        vault.deposit(address(0), 42e5);
    }

    function test_depositRevertIfEthIncorrectMsgValue() public {
        uint256 amount = 42e5;
        vm.deal(someone, amount * 2);
        vm.expectRevert(abi.encodeWithSelector(IVault.IncorrectValue.selector));
        vm.prank(someone);
        vault.deposit{value: amount + 42}(address(0), amount);
    }

    function test_depositRevertIfERC20AndValue() public {
        uint256 amount = 42e5;
        token1.mint(someone, amount);
        vm.deal(someone, amount);

        vm.prank(someone);
        token1.approve(address(vault), type(uint256).max);
        vm.expectRevert(abi.encodeWithSelector(IVault.IncorrectValue.selector));
        vm.prank(someone);
        vault.deposit{value: 42}(address(token1), amount);
    }

    function test_emitsEventDeposited() public {
        uint256 amount = 42e5;
        token1.mint(someone, amount);

        vm.prank(someone);
        token1.approve(address(vault), type(uint256).max);

        vm.expectEmit(true, true, true, true);
        emit IVault.Deposited(someone, address(token1), amount);
        vm.prank(someone);
        vault.deposit(address(token1), amount);
    }

    function test_withdrawETH() public {
        uint256 depositAmount = 42e5;
        uint256 withdrawAmount = 42e4;

        // Deposit ETH first
        vm.deal(someone, depositAmount);
        vm.prank(someone);
        vault.deposit{value: depositAmount}(address(0), depositAmount);

        // Withdraw ETH
        vm.prank(someone);
        vault.withdraw(address(0), withdrawAmount);
        assertEq(someone.balance, withdrawAmount);
        assertEq(address(vault).balance, ethBalance + depositAmount - withdrawAmount);
    }

    function test_withdrawETH_costlyReceiver() public {
        CostlyReceiver receiver = new CostlyReceiver();

        uint256 depositAmount = 42e5;
        uint256 withdrawAmount = 42e4;

        // Deposit ETH first
        vm.deal(address(receiver), depositAmount);
        vm.prank(address(receiver));
        vault.deposit{value: depositAmount}(address(0), depositAmount);

        // Withdraw ETH
        vm.prank(address(receiver));
        vault.withdraw(address(0), withdrawAmount);
        assertEq(address(receiver).balance, withdrawAmount);
        assertEq(address(vault).balance, ethBalance + depositAmount - withdrawAmount);
    }

    function test_withdrawERC20() public {
        uint256 depositAmount = 42e5;
        uint256 withdrawAmount = 42e4;

        // Deposit tokens first
        token1.mint(someone, depositAmount);
        vm.startPrank(someone);
        token1.approve(address(vault), type(uint256).max);
        vault.deposit(address(token1), depositAmount);
        vm.stopPrank();

        // Withdraw tokens
        vm.prank(someone);
        vault.withdraw(address(token1), withdrawAmount);
        assertEq(token1.balanceOf(someone), withdrawAmount);
        assertEq(vault.balanceOf(someone, address(token1)), depositAmount - withdrawAmount);
    }

    function test_withdrawRevertIfUnauthorizedETH() public {
        FalseAuthorize falseAuth = new FalseAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(falseAuth);

        vm.warp(TIME + WITHDRAWAL_GRACE_PERIOD);

        uint256 depositAmount = 42e5;
        uint256 withdrawAmount = 42e4;

        // Deposit tokens first
        vm.deal(someone, depositAmount);
        vm.startPrank(someone);
        vault.deposit{value: depositAmount}(address(0), depositAmount);
        vm.stopPrank();

        // Withdraw tokens
        vm.expectRevert(abi.encodeWithSelector(IAuthorize.Unauthorized.selector, someone, address(0), withdrawAmount));
        vm.prank(someone);
        vault.withdraw(address(0), withdrawAmount);
    }

    function test_withdrawRevertIfUnauthorizedERC20() public {
        FalseAuthorize falseAuth = new FalseAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(falseAuth);

        vm.warp(TIME + WITHDRAWAL_GRACE_PERIOD);

        uint256 depositAmount = 42e5;
        uint256 withdrawAmount = 42e4;

        // Deposit tokens first
        token1.mint(someone, depositAmount);
        vm.startPrank(someone);
        token1.approve(address(vault), type(uint256).max);
        vault.deposit(address(token1), depositAmount);
        vm.stopPrank();

        // Withdraw tokens
        vm.expectRevert(
            abi.encodeWithSelector(IAuthorize.Unauthorized.selector, someone, address(token1), withdrawAmount)
        );
        vm.prank(someone);
        vault.withdraw(address(token1), withdrawAmount);
    }

    function test_withdrawERC20_ifAuthorizerHasChanged() public {
        FalseAuthorize newAuthorizer = new FalseAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(newAuthorizer);

        uint256 time = TIME + WITHDRAWAL_GRACE_PERIOD;
        vm.warp(time);

        uint256 depositAmount = 42e5;
        uint256 withdraw1Amount = 42e4;
        uint256 withdraw2Amount = 1e4;

        // Deposit tokens first
        token1.mint(someone, depositAmount);
        vm.startPrank(someone);
        token1.approve(address(vault), type(uint256).max);
        vault.deposit(address(token1), depositAmount);
        vm.stopPrank();

        time += 1 days;
        vm.warp(time);

        // Revert on withdraw
        vm.expectRevert(
            abi.encodeWithSelector(IAuthorize.Unauthorized.selector, someone, address(token1), withdraw1Amount)
        );
        vm.prank(someone);
        vault.withdraw(address(token1), withdraw1Amount);

        // Change authorizer
        newAuthorizer = new FalseAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(newAuthorizer);

        time += 1 days;
        vm.warp(time);

        // Withdraw tokens
        vm.prank(someone);
        vault.withdraw(address(token1), withdraw1Amount);
        assertEq(token1.balanceOf(someone), withdraw1Amount);
        assertEq(vault.balanceOf(someone, address(token1)), depositAmount - withdraw1Amount);

        // Grace period has ended
        time += WITHDRAWAL_GRACE_PERIOD;
        vm.warp(time);

        // Revert on withdraw
        vm.expectRevert(
            abi.encodeWithSelector(IAuthorize.Unauthorized.selector, someone, address(token1), withdraw2Amount)
        );
        vm.prank(someone);
        vault.withdraw(address(token1), withdraw2Amount);
    }

    function test_ERC20FullFlow() public {
        uint256 depositAmount = token1Balance;
        uint256 withdrawAmount = 42e4;

        // Mint and deposit tokens
        token2.mint(someone, depositAmount);
        vm.startPrank(someone);
        token2.approve(address(vault), type(uint256).max);
        vault.deposit(address(token2), depositAmount);
        vm.stopPrank();

        assertEq(token2.balanceOf(address(vault)), depositAmount);

        // Withdraw tokens
        vm.prank(someone);
        vault.withdraw(address(token2), withdrawAmount);
        assertEq(token2.balanceOf(someone), withdrawAmount);
        assertEq(token2.balanceOf(address(vault)), depositAmount - withdrawAmount);
    }

    function test_revertIfInsufficientBalance() public {
        vm.expectRevert(abi.encodeWithSelector(IVault.InsufficientBalance.selector, address(token1), token1Balance, 0));
        vm.prank(someone);
        vault.withdraw(address(token1), token1Balance);
    }

    function test_emitsEventWithdrawn() public {
        uint256 depositAmount = 42e5;
        uint256 withdrawAmount = 42e4;

        // Deposit tokens first
        token1.mint(someone, depositAmount);
        vm.startPrank(someone);
        token1.approve(address(vault), type(uint256).max);
        vault.deposit(address(token1), depositAmount);
        vm.stopPrank();

        // Withdraw tokens
        vm.expectEmit(true, true, true, true);
        emit IVault.Withdrawn(someone, address(token1), withdrawAmount);
        vm.prank(someone);
        vault.withdraw(address(token1), withdrawAmount);
    }
}
