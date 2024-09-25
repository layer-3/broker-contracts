// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, Vm} from "forge-std/Test.sol";

import {ClaimExecutor} from "../../../src/voucher/executors/ClaimExecutor.sol";
import {TestClaimExecutor} from "../../../src/voucher/executors/test/TestClaimExecutor.sol";

uint256 constant TIME = 1716051867;

contract ClaimExecutorTest_integration is Test {
    TestClaimExecutor claimExec;

    address router = vm.createWallet("router").addr;
    address user1 = vm.createWallet("user1").addr;
    address user2 = vm.createWallet("user2").addr;

    function setUp() public {
        claimExec = new TestClaimExecutor(router);
        vm.warp(TIME);
    }

    function enc(uint64 points) internal pure returns (bytes memory) {
        return abi.encode(ClaimExecutor.DailyClaimPayload(points));
    }

    /// @dev all expected streak logic is here
    function performAndAssertUserCheckin(address user, uint64 points, uint128 expectedUserStreak) public {
        vm.expectEmit(address(claimExec));
        emit ClaimExecutor.Claimed(user, points, expectedUserStreak);
        claimExec.exposed_execute(user, enc(points));

        (uint64 claimTime, uint128 streakCount) = claimExec.usersData(user);
        assertEq(claimTime, block.timestamp, "Incorrect latestClaimTimestamp");
        assertEq(streakCount, expectedUserStreak, "Incorrect streakCount");
    }

    function test_flow() public {
        uint256 time = TIME;
        // Day 1
        performAndAssertUserCheckin(user1, 42, 1);

        // Day 2
        time += 1 days + 1 hours;
        vm.warp(time);
        performAndAssertUserCheckin(user1, 15, 2);
        performAndAssertUserCheckin(user2, 28, 1);

        // Day 3
        time += 1 days - 1 hours;
        vm.warp(time);
        performAndAssertUserCheckin(user1, 110, 3);
        performAndAssertUserCheckin(user2, 39, 2);

        // Day 4 - user1 skips
        time += 1 days;
        vm.warp(time);
        performAndAssertUserCheckin(user2, 42, 3);

        // Day 5
        time += 1 days;
        vm.warp(time);
        performAndAssertUserCheckin(user1, 5, 1);
        performAndAssertUserCheckin(user2, 142, 4);

        // Day 6
        time += 1 days;
        vm.warp(time);
        performAndAssertUserCheckin(user1, 19, 2);
        performAndAssertUserCheckin(user2, 200, 5);

        // Day 7
        time += 1 days;
        vm.warp(time);
        performAndAssertUserCheckin(user1, 39, 3);
        performAndAssertUserCheckin(user2, 420, 6);
    }
}
