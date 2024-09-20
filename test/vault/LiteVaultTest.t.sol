// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Test, Vm} from "forge-std/Test.sol";

import {CostlyReceiver} from "./CostlyReceiver.sol";
import {TestLiteVault} from "../../src/vault/test/TestLiteVault.sol";
import {IVault} from "../../src/interfaces/IVault.sol";
import {IAuthorize} from "../../src/interfaces/IAuthorize.sol";
import {IAuthorizable} from "../../src/interfaces/IAuthorizable.sol";
import {TrueAuthorize, FalseAuthorize} from "./MockedAuthorizer.sol";
import {TestERC20} from "../TestERC20.sol";

uint256 constant TIME = 1716051867;

contract LiteVaultTestBase is Test {
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

    function setUp() public virtual {
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
}

contract LiteVaultTest_constructor is LiteVaultTestBase {
    function test_correctOwnerAndAuthorizer() public view {
        assertEq(vault.owner(), owner);
        assertEq(address(vault.authorizer()), address(trueAuthorizer));
    }

    function test_revert_ifInvalidAuthorizerAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IVault.InvalidAddress.selector));
        new TestLiteVault(owner, IAuthorize(address(0)));
    }
}

contract LiteVaultTest is LiteVaultTestBase {
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
}

contract LiteVaultTest_setAuthorizer is LiteVaultTestBase {
    function test_success_IfOwner() public {
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

    function test_revert_ifNotOwner() public {
        FalseAuthorize newAuthorizer = new FalseAuthorize();
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, someone));
        vm.prank(someone);
        vault.setAuthorizer(newAuthorizer);
    }

    function test_revert_ifAuthorizerZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IVault.InvalidAddress.selector));
        vm.prank(owner);
        vault.setAuthorizer(IAuthorize(address(0)));
    }

    function test_emitEvent() public {
        TrueAuthorize newAuthorizer = new TrueAuthorize();
        vm.expectEmit(true, true, true, true);
        emit IAuthorizable.AuthorizerChanged(newAuthorizer);
        vm.prank(owner);
        vault.setAuthorizer(newAuthorizer);
    }
}

contract LiteVaultTest_deposit is LiteVaultTestBase {
    uint256 public constant ETH_AMOUNT = 42e5;
    uint256 public constant ERC20_AMOUNT = 424e6;

    function setUp() public virtual override {
        super.setUp();
        vm.deal(someone, ETH_AMOUNT);
        token1.mint(someone, ERC20_AMOUNT);
        vm.prank(someone);
        token1.approve(address(vault), type(uint256).max);
    }

    function test_success_ETH() public {
        vm.prank(someone);
        vault.deposit{value: ETH_AMOUNT}(address(0), ETH_AMOUNT);
        assertEq(address(vault).balance, ethBalance + ETH_AMOUNT);
        assertEq(someone.balance, 0);
    }

    function test_success_ERC20() public {
        vm.prank(someone);
        vault.deposit(address(token1), ERC20_AMOUNT);
        assertEq(token1.balanceOf(address(vault)), token1Balance + ERC20_AMOUNT);
        assertEq(token1.balanceOf(someone), 0);
    }

    function test_revert_ifEthNoMsgValue() public {
        vm.expectRevert(abi.encodeWithSelector(IVault.IncorrectValue.selector));
        vm.prank(someone);
        vault.deposit(address(0), 42e5);
    }

    function test_revert_ifEthIncorrectMsgValue() public {
        vm.expectRevert(abi.encodeWithSelector(IVault.IncorrectValue.selector));
        vm.prank(someone);
        vault.deposit{value: ETH_AMOUNT - 42}(address(0), ETH_AMOUNT);
    }

    function test_revert_ifERC20AndValue() public {
        vm.expectRevert(abi.encodeWithSelector(IVault.IncorrectValue.selector));
        vm.prank(someone);
        vault.deposit{value: 42}(address(token1), ERC20_AMOUNT);
    }

    function test_emitsEvent() public {
        vm.expectEmit(true, true, true, true);
        emit IVault.Deposited(someone, address(token1), ERC20_AMOUNT);
        vm.prank(someone);
        vault.deposit(address(token1), ERC20_AMOUNT);
    }
}

contract LiteVaultTest_withdraw is LiteVaultTestBase {
    uint256 public constant ETH_DEP_AMOUNT = 42e5;
    uint256 public constant ERC20_DEP_AMOUNT = 424e6;
    uint256 public constant ETH_WITH_AMOUNT = 41e5;
    uint256 public constant ERC20_WITH_AMOUNT = 224e6;

    function setUp() public virtual override {
        super.setUp();
        vm.deal(someone, ETH_DEP_AMOUNT);
        token1.mint(someone, ERC20_DEP_AMOUNT);

        vm.startPrank(someone);
        vault.deposit{value: ETH_DEP_AMOUNT}(address(0), ETH_DEP_AMOUNT);
        token1.approve(address(vault), type(uint256).max);
        vault.deposit(address(token1), ERC20_DEP_AMOUNT);
        vm.stopPrank();
    }

    function test_success_ETH() public {
        vm.prank(someone);
        vault.withdraw(address(0), ETH_WITH_AMOUNT);
        assertEq(someone.balance, ETH_WITH_AMOUNT);
        assertEq(address(vault).balance, ethBalance + ETH_DEP_AMOUNT - ETH_WITH_AMOUNT);
    }

    function test_success_ETH_costlyReceiver() public {
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
        assertEq(address(vault).balance, ethBalance + ETH_DEP_AMOUNT + depositAmount - withdrawAmount);
    }

    function test_success_ERC20() public {
        // Withdraw tokens
        vm.prank(someone);
        vault.withdraw(address(token1), ERC20_WITH_AMOUNT);
        assertEq(token1.balanceOf(someone), ERC20_WITH_AMOUNT);
        assertEq(vault.balanceOf(someone, address(token1)), ERC20_DEP_AMOUNT - ERC20_WITH_AMOUNT);
    }

    function test_revert_ifUnauthorizedETH() public {
        FalseAuthorize falseAuth = new FalseAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(falseAuth);

        vm.warp(TIME + WITHDRAWAL_GRACE_PERIOD);

        // Withdraw tokens
        vm.expectRevert(abi.encodeWithSelector(IAuthorize.Unauthorized.selector, someone, address(0), ETH_WITH_AMOUNT));
        vm.prank(someone);
        vault.withdraw(address(0), ETH_WITH_AMOUNT);
    }

    function test_revert_ifUnauthorizedERC20() public {
        FalseAuthorize falseAuth = new FalseAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(falseAuth);

        vm.warp(TIME + WITHDRAWAL_GRACE_PERIOD);

        // Withdraw tokens
        vm.expectRevert(
            abi.encodeWithSelector(IAuthorize.Unauthorized.selector, someone, address(token1), ERC20_WITH_AMOUNT)
        );
        vm.prank(someone);
        vault.withdraw(address(token1), ERC20_WITH_AMOUNT);
    }

    function test_success_ERC20_ifGracePeriodActive() public {
        // Change authorizer
        FalseAuthorize newAuthorizer = new FalseAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(newAuthorizer);

        vm.warp(TIME + 1 days);

        // Withdraw tokens
        vm.prank(someone);
        vault.withdraw(address(token1), ERC20_WITH_AMOUNT);
        assertEq(token1.balanceOf(someone), ERC20_WITH_AMOUNT);
        assertEq(vault.balanceOf(someone, address(token1)), ERC20_DEP_AMOUNT - ERC20_WITH_AMOUNT);
    }

    function test_authRules_ETH_ifGracePeriodEnded() public {
        // Change authorizer
        FalseAuthorize newAuthorizer = new FalseAuthorize();
        vm.prank(owner);
        vault.setAuthorizer(newAuthorizer);

        vm.warp(TIME + 1 hours + WITHDRAWAL_GRACE_PERIOD);

        // Revert on withdraw
        vm.expectRevert(abi.encodeWithSelector(IAuthorize.Unauthorized.selector, someone, address(0), ETH_WITH_AMOUNT));
        vm.prank(someone);
        vault.withdraw(address(0), ETH_WITH_AMOUNT);
    }

    function test_revert_ifInsufficientBalance_ETH() public {
        vm.expectRevert(
            abi.encodeWithSelector(IVault.InsufficientBalance.selector, address(0), ETH_DEP_AMOUNT + 1, ETH_DEP_AMOUNT)
        );
        vm.prank(someone);
        vault.withdraw(address(0), ETH_DEP_AMOUNT + 1);
    }

    function test_revert_ifInsufficientBalance_ERC20() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IVault.InsufficientBalance.selector, address(token1), ERC20_DEP_AMOUNT + 1, ERC20_DEP_AMOUNT
            )
        );
        vm.prank(someone);
        vault.withdraw(address(token1), ERC20_DEP_AMOUNT + 1);
    }

    function test_emitsEvent() public {
        // Withdraw tokens
        vm.expectEmit(true, true, true, true);
        emit IVault.Withdrawn(someone, address(token1), ERC20_WITH_AMOUNT);
        vm.prank(someone);
        vault.withdraw(address(token1), ERC20_WITH_AMOUNT);
    }
}
