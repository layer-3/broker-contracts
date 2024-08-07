// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/vault/LiteVault.sol";
import "../src/interfaces/IVault.sol";
import "./MockAuthorize.sol";
import "./TestERC20.sol";

contract LiteVaultTest is Test {
    LiteVault vault;
    TestERC20 token1;
    TestERC20 token2;
    MockAuthorize mockAuthorizer;

    address deployer = address(1);
    address owner = address(2);
    address someone = address(3);

    uint256 ethBalance = 1 ether;
    uint256 token1Balance = 42e6;

    function setUp() public {
        mockAuthorizer = new MockAuthorize();
        vm.prank(deployer);
        vault = new LiteVault(owner);
        vm.prank(owner);
        vault.setAuthorizer(mockAuthorizer);

        token1 = new TestERC20("Test1", "TST1", 18, type(uint256).max);
        token2 = new TestERC20("Test2", "TST2", 18, type(uint256).max);
        token1.mint(address(vault), token1Balance);
        vm.deal(address(vault), ethBalance);
    }

    function test_constructor() public view {
        assertEq(vault.owner(), owner);
    }

    function test_receive() public {
        uint256 amount = 42e5;
        vm.deal(someone, amount);
        vm.prank(someone);
        payable(address(vault)).transfer(amount);
        assertEq(address(vault).balance, ethBalance + amount);
    }

    function test_successEth() public {
        uint256 amount = 42e5;
        vm.deal(someone, amount);

        vm.prank(someone);
        vault.deposit{value: amount}(address(0), amount);
        assertEq(address(vault).balance, ethBalance + amount);
        assertEq(someone.balance, 0);
    }

    function test_successERC20() public {
        uint256 amount = 42e5;
        token1.mint(someone, amount);

        vm.prank(someone);
        token1.approve(address(vault), type(uint256).max);
        vm.prank(someone);
        vault.deposit(address(token1), amount);
        assertEq(token1.balanceOf(address(vault)), token1Balance + amount);
        assertEq(token1.balanceOf(someone), 0);
    }

    function test_revertIfEthNoMsgValue() public {
        vm.expectRevert(abi.encodeWithSelector(IVault.IncorrectValue.selector));
        vm.prank(someone);
        vault.deposit(address(0), 42e5);
    }

    function test_revertIfEthIncorrectMsgValue() public {
        uint256 amount = 42e5;
        vm.deal(someone, amount * 2);
        vm.expectRevert(abi.encodeWithSelector(IVault.IncorrectValue.selector));
        vm.prank(someone);
        vault.deposit{value: amount + 42}(address(0), amount);
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
        assertEq(
            vault.balanceOf(someone, address(token1)),
            depositAmount - withdrawAmount
        );
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
        assertEq(
            address(vault).balance,
            ethBalance + depositAmount - withdrawAmount
        );
    }

    // TODO: add test for unauthorized withdrawal

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
        assertEq(
            token2.balanceOf(address(vault)),
            depositAmount - withdrawAmount
        );
    }

    function test_revertIfInsufficientBalance() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IVault.InsufficientBalance.selector,
                address(token1),
                token1Balance,
                0
            )
        );
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
