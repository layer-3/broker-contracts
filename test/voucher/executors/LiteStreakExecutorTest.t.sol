// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Test, Vm} from "forge-std/Test.sol";

import {LiteStreakExecutor} from "../../../src/voucher/executors/LiteStreakExecutor.sol";
import {TestLiteStreakExecutor} from "../../../src/voucher/executors/test/TestLiteStreakExecutor.sol";
import {IVoucherExecutor} from "../../../src/interfaces/IVoucherExecutor.sol";

uint256 constant TIME = 1716051867;

contract LiteStreakExecutorTestBase is Test {
    TestLiteStreakExecutor streakExec;

    address router = vm.createWallet("router").addr;
    address beneficiary = vm.createWallet("beneficiary").addr;
    Vm.Wallet Someone = vm.createWallet("someone");
    Vm.Wallet Someother = vm.createWallet("someother");
    Vm.Wallet Owner = vm.createWallet("owner");

    uint128 constant STREAK_SIZE = 7;
    uint256 constant REGULAR_POINTS = 10;
    uint256 constant STREAK_POINTS = 100;

    constructor() {
        vm.warp(TIME); // to avoid `RewardOnCooldown` errors because of zero-initialized user claim timestamps
        streakExec = new TestLiteStreakExecutor(Owner.addr, router);
    }
}

contract LiteStreakExecutorTest is LiteStreakExecutorTestBase {
    function test_constructor() public view {
        assertEq(streakExec.owner(), Owner.addr, "Incorrect owner");
        assertEq(streakExec.router(), router, "Incorrect router");
    }

    // getters
    function test_getCheckinData() public {
        uint128 latestCheckinDay = 42;
        uint128 streakCount = 7;

        streakExec.workaround_setCheckinData(Someone.addr, latestCheckinDay, streakCount);

        LiteStreakExecutor.CheckinData memory checkinData = streakExec.getCheckinData(Someone.addr);
        assertEq(checkinData.latestCheckinDay, latestCheckinDay, "Incorrect latestCheckinDay");
        assertEq(checkinData.streakCount, streakCount, "Incorrect streakCount");
    }

    function test_getCheckinData_emptyUser() public view {
        LiteStreakExecutor.CheckinData memory checkinData = streakExec.getCheckinData(Someother.addr);
        assertEq(checkinData.latestCheckinDay, 0, "Incorrect latestCheckinDay");
        assertEq(checkinData.streakCount, 0, "Incorrect streakCount");
    }
}

contract LiteStreakExecutorTest_setConfig is LiteStreakExecutorTestBase {
    function test_setConfig_successIfOwner() public {
        uint128 streakSize = 42;
        uint256 regularPoints = 10;
        uint256 streakPoints = 15;
        vm.prank(Owner.addr);
        streakExec.setConfig(streakSize, regularPoints, streakPoints);
        assertEq(streakExec.streakSize(), streakSize, "Incorrect streakSize");
    }

    function test_setConfig_revertIfNotOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, Someone.addr));
        vm.prank(Someone.addr);
        streakExec.setConfig(42, 42, 42);
    }
}

contract LiteStreakExecutorTest_checkin is LiteStreakExecutorTestBase {
    function test_success() public {
        uint128 streakCount = 0;

        streakExec.exposed_execute(beneficiary, "");

        LiteStreakExecutor.CheckinData memory checkinData = streakExec.getCheckinData(beneficiary);
        assertEq(checkinData.latestCheckinDay, uint128(block.timestamp / 1 days), "Incorrect latestCheckinDay");
        assertEq(checkinData.streakCount, streakCount + 1, "Incorrect streakCount");
    }

    function test_eventEmitted() public {
        uint128 expectedStreak = 1;
        vm.expectEmit(true, true, true, true, address(streakExec));
        emit LiteStreakExecutor.Checkin(beneficiary, expectedStreak, REGULAR_POINTS);
        streakExec.exposed_execute(beneficiary, "");
    }

    function test_eventEmitted_withRegularPoints_ifNotStreak() public {
        uint128 expectedStreak = 1;
        vm.expectEmit(true, true, true, true, address(streakExec));
        emit LiteStreakExecutor.Checkin(beneficiary, expectedStreak, REGULAR_POINTS);
        streakExec.exposed_execute(beneficiary, "");
    }

    function test_eventEmitted_withStreakPoints_ifStreak() public {
        uint128 latestCheckinDay = uint128(block.timestamp / 1 days - 1);
        uint128 streakCount = STREAK_SIZE - 1;
        streakExec.workaround_setCheckinData(beneficiary, latestCheckinDay, streakCount);

        vm.expectEmit(true, true, true, true, address(streakExec));
        emit LiteStreakExecutor.Checkin(beneficiary, STREAK_SIZE, STREAK_POINTS);
        streakExec.exposed_execute(beneficiary, "");
    }

    function test_eventEmitted_withStreakCount_ifReached() public {
        uint128 latestCheckinDay = uint128(block.timestamp / 1 days - 1);
        uint128 streakCount = STREAK_SIZE - 1;
        streakExec.workaround_setCheckinData(beneficiary, latestCheckinDay, streakCount);

        vm.expectEmit(true, true, true, true, address(streakExec));
        emit LiteStreakExecutor.Checkin(beneficiary, STREAK_SIZE, STREAK_POINTS);
        streakExec.exposed_execute(beneficiary, "");
    }

    function test_streakDayIncreased_ifStreakNotReached() public {
        uint128 latestCheckinDay = uint128(block.timestamp / 1 days - 1);
        uint128 streakCount = STREAK_SIZE - 2;
        streakExec.workaround_setCheckinData(beneficiary, latestCheckinDay, streakCount);

        uint128 expectedStreak = streakCount + 1;
        streakExec.exposed_execute(beneficiary, "");
        uint128 actualStreak = streakExec.getCheckinData(beneficiary).streakCount;
        assertEq(actualStreak, expectedStreak, "Incorrect streakCount");
    }

    function test_streakReset_ifStreakReached() public {
        uint128 latestCheckinDay = uint128(block.timestamp / 1 days - 1);
        uint128 streakCount = STREAK_SIZE - 1;
        streakExec.workaround_setCheckinData(beneficiary, latestCheckinDay, streakCount);

        streakExec.exposed_execute(beneficiary, "");
        uint128 actualStreak = streakExec.getCheckinData(beneficiary).streakCount;
        assertEq(actualStreak, 0, "Incorrect streakCount");
    }

    function test_revert_ifOnCooldown() public {
        uint128 latestCheckinDay = uint128(block.timestamp / 1 days);
        uint128 streakCount = uint128(streakExec.streakSize());
        streakExec.workaround_setCheckinData(beneficiary, latestCheckinDay, streakCount);

        vm.warp(block.timestamp + 1 hours);
        vm.expectRevert(
            abi.encodeWithSelector(
                LiteStreakExecutor.CheckinOnCooldown.selector, (block.timestamp / 1 days + 1) * 1 days
            )
        );
        streakExec.exposed_execute(beneficiary, "");
    }

    function test_resetStreak_ifMoreThanTwoDaysPassed() public {
        uint128 latestCheckinDay = uint128(block.timestamp / 1 days - 2);
        uint128 streakCount = uint128(streakExec.streakSize() - 1);
        streakExec.workaround_setCheckinData(beneficiary, latestCheckinDay, streakCount);

        streakExec.exposed_execute(beneficiary, "");

        LiteStreakExecutor.CheckinData memory checkinData = streakExec.getCheckinData(beneficiary);
        assertEq(checkinData.latestCheckinDay, uint128(block.timestamp / 1 days), "Incorrect latestCheckinDay");
        assertEq(checkinData.streakCount, 1, "Incorrect streakCount");
    }
}
