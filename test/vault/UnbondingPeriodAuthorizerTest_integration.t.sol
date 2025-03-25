// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, Vm} from "forge-std/Test.sol";

import {LiteVault} from "../../src/vault/LiteVault.sol";
import {UnbondingPeriodAuthorizer} from "../../src/vault/UnbondingPeriodAuthorizer.sol";
import {TestERC20} from "../TestERC20.sol";
import {IAuthorize} from "../../src/interfaces/IAuthorize.sol";

uint256 constant TIME = 1716051867;

contract UnbondingPeriodAuthorizerTest_integration is Test {
    UnbondingPeriodAuthorizer authorizer;
    LiteVault vault;
    TestERC20 token;

    address deployer = vm.createWallet("deployer").addr;
    address owner = vm.createWallet("owner").addr;
    address user = vm.createWallet("user").addr;

    uint64 constant UNBONDING_PERIOD = 7 days;
    uint256 constant DEPOSIT_AMOUNT = 1000e18;

    function setUp() public {
        uint64[] memory supportedPeriods = new uint64[](1);
        supportedPeriods[0] = UNBONDING_PERIOD;

        vm.prank(deployer);
        authorizer = new UnbondingPeriodAuthorizer(owner, supportedPeriods);

        vm.prank(deployer);
        vault = new LiteVault(owner, authorizer);

        token = new TestERC20("Test", "TST", 18, type(uint256).max);

        token.mint(user, DEPOSIT_AMOUNT);

        vm.warp(TIME);
    }

    function test_depositAndWithdrawFlow() public {
        vm.startPrank(user);
        token.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(address(token), DEPOSIT_AMOUNT);
        vm.stopPrank();

        assertEq(token.balanceOf(user), 0, "User balance should be 0 after deposit");
        assertEq(token.balanceOf(address(vault)), DEPOSIT_AMOUNT, "Vault balance should equal deposit amount");
        assertEq(
            vault.balanceOf(user, address(token)), DEPOSIT_AMOUNT, "User balance in vault should equal deposit amount"
        );

        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(UnbondingPeriodAuthorizer.UnbondingNotRequested.selector, user, address(token))
        );
        vault.withdraw(address(token), DEPOSIT_AMOUNT);

        vm.prank(user);
        authorizer.requestUnbonding(address(token), UNBONDING_PERIOD);

        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnbondingPeriodAuthorizer.UnbondingPeriodNotExpired.selector,
                uint64(TIME),
                uint64(TIME),
                UNBONDING_PERIOD
            )
        );
        vault.withdraw(address(token), DEPOSIT_AMOUNT);

        vm.warp(TIME + UNBONDING_PERIOD - 1);

        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnbondingPeriodAuthorizer.UnbondingPeriodNotExpired.selector,
                uint64(TIME),
                uint64(TIME + UNBONDING_PERIOD - 1),
                UNBONDING_PERIOD
            )
        );
        vault.withdraw(address(token), DEPOSIT_AMOUNT);

        vm.warp(TIME + UNBONDING_PERIOD + 1);

        vm.prank(user);
        authorizer.completeUnbondingRequest(address(token));

        assertFalse(
            authorizer.hasActiveUnbondingRequest(user, address(token)),
            "Unbonding request should be deleted after completion"
        );

        // Now the withdrawal should fail as there's no active request to authorize
        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(UnbondingPeriodAuthorizer.UnbondingNotRequested.selector, user, address(token))
        );
        vault.withdraw(address(token), DEPOSIT_AMOUNT);

        vm.prank(user);
        authorizer.requestUnbonding(address(token), UNBONDING_PERIOD);

        vm.warp(TIME + UNBONDING_PERIOD * 2 + 1);

        // Now withdrawal should succeed without explicitly completing the request first
        // The vault will call authorizer.authorize() which checks the unbonding period has passed
        vm.prank(user);
        vault.withdraw(address(token), DEPOSIT_AMOUNT);

        assertEq(token.balanceOf(user), DEPOSIT_AMOUNT, "User balance should equal deposit amount after withdrawal");
        assertEq(token.balanceOf(address(vault)), 0, "Vault balance should be 0 after withdrawal");
        assertEq(vault.balanceOf(user, address(token)), 0, "User balance in vault should be 0 after withdrawal");

        // Verify the request still exists after withdrawal
        // LiteVault only calls authorize() which doesn't delete the request
        assertTrue(
            authorizer.hasActiveUnbondingRequest(user, address(token)),
            "Unbonding request should still exist after withdrawal"
        );
    }
}
