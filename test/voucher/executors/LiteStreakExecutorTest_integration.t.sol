// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, Vm} from "forge-std/Test.sol";

import {LiteStreakExecutor} from "../../../src/voucher/executors/LiteStreakExecutor.sol";
import {TestLiteStreakExecutor} from "../../../src/voucher/executors/test/TestLiteStreakExecutor.sol";
import {IVoucherExecutor} from "../../../src/interfaces/IVoucherExecutor.sol";

contract LiteStreakExecutorTest_integration is Test {
    TestLiteStreakExecutor streakExec;

    address router = vm.createWallet("router").addr;
    Vm.Wallet Owner = vm.createWallet("owner");
    address user1 = vm.createWallet("user1").addr;
    address user2 = vm.createWallet("user2").addr;

    uint128 streakSize;
    uint256 constant REGULAR_POINTS = 10;
    uint256 constant STREAK_POINTS = 100;

    uint256 time = 1716051867;

    function setUp() public {
        vm.warp(time); // to avoid `RewardOnCooldown` errors because of zero-initialized user claim timestamps
        streakExec = new TestLiteStreakExecutor(Owner.addr, router);
        streakSize = streakExec.streakSize();
    }

    /// @dev all expected streak logic is here
    function performAndAssertUserCheckin(address user, uint128 expectedUserStreak) public {
        uint128 expectedEventStreak = expectedUserStreak == 0 ? streakSize : expectedUserStreak;
        /// @dev Streak size 0 means the streak has been reached, therefore a user should have received streakPoints
        uint256 expectedPoints = expectedEventStreak >= streakSize ? STREAK_POINTS : REGULAR_POINTS;
        vm.expectEmit(true, true, true, true, address(streakExec));
        emit LiteStreakExecutor.Checkin(user, expectedEventStreak, expectedPoints);
        vm.prank(user);
        streakExec.exposed_execute(user, "");

        LiteStreakExecutor.CheckinData memory checkinData = streakExec.getCheckinData(user);
        assertEq(
            checkinData.latestCheckinDay,
            // checkinData.latestCheckinDay is set to the current day
            block.timestamp / 1 days,
            "Incorrect latestCheckinDay"
        );
        assertEq(checkinData.streakCount, expectedUserStreak, "Incorrect streakCount");
    }

    function test_flow() public {
        // Day 1
        performAndAssertUserCheckin(user1, 1);

        // Day 2
        time += 1 days;
        vm.warp(time);

        performAndAssertUserCheckin(user1, 2);
        performAndAssertUserCheckin(user2, 1);

        // user2 tries to checkin again on the same day
        vm.expectRevert(
            abi.encodeWithSelector(
                LiteStreakExecutor.CheckinOnCooldown.selector, (block.timestamp / 1 days + 1) * 1 days
            )
        );
        streakExec.exposed_execute(user2, "");

        // Day 3
        time += 1 days;
        vm.warp(time);

        performAndAssertUserCheckin(user1, 3);
        performAndAssertUserCheckin(user2, 2);

        // Day 4
        // user2 misses a day
        time += 1 days;
        vm.warp(time);

        performAndAssertUserCheckin(user1, 4);

        // Day 5
        time += 1 days;
        vm.warp(time);

        performAndAssertUserCheckin(user1, 5);
        // Streak is reset for user2
        performAndAssertUserCheckin(user2, 1);

        // Day 6
        time += 1 days;
        vm.warp(time);

        performAndAssertUserCheckin(user1, 6);
        performAndAssertUserCheckin(user2, 2);

        // Day 7
        time += 1 days;
        vm.warp(time);

        // user1 has reached the streak, it should reset
        performAndAssertUserCheckin(user1, 0);
        performAndAssertUserCheckin(user2, 3);

        // Day 8
        time += 1 days;
        vm.warp(time);

        performAndAssertUserCheckin(user1, 1);
        performAndAssertUserCheckin(user2, 4);

        // Day 9
        // user1 misses a day
        time += 1 days;
        vm.warp(time);

        performAndAssertUserCheckin(user2, 5);

        // Day 10
        time += 1 days;
        vm.warp(time);

        performAndAssertUserCheckin(user1, 1);
        performAndAssertUserCheckin(user2, 6);

        // Day 11
        time += 1 days;
        vm.warp(time);

        performAndAssertUserCheckin(user1, 2);
        // user2 has reached the streak, it should reset
        performAndAssertUserCheckin(user2, 0);
    }
}
