// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, Vm} from "forge-std/Test.sol";

import {ClaimExecutor} from "../../../src/voucher/executors/ClaimExecutor.sol";
import {TestClaimExecutor} from "../../../src/voucher/executors/test/TestClaimExecutor.sol";
import {IVoucherExecutor} from "../../../src/interfaces/IVoucherExecutor.sol";

uint256 constant TIME = 1716051867;

contract ClaimExecutorTest is Test {
    TestClaimExecutor claimExec;

    address router = vm.createWallet("router").addr;
    address beneficiary = vm.createWallet("beneficiary").addr;

    uint256 cooldownDays;

    function setUp() public virtual {
        claimExec = new TestClaimExecutor(router);
        cooldownDays = claimExec.COOLDOWN_DAYS();
        vm.warp(TIME);
    }

    function enc(uint64 points) internal pure returns (bytes memory) {
        return abi.encode(ClaimExecutor.DailyClaimPayload(points));
    }
}

contract ClaimExecutorTest_constructor is ClaimExecutorTest {
    function test_constructor() public view {
        assertEq(claimExec.router(), router, "Incorrect router");
    }
}

contract ClaimExecutorTest_execute is ClaimExecutorTest {
    function test_correctPointsAndStreakInEvent_ifNotOnCooldown() public {
        uint64 points = 42;
        vm.expectEmit();
        emit ClaimExecutor.Claimed(beneficiary, points, 1);
        claimExec.exposed_execute(beneficiary, enc(points));
    }

    function test_streakDayAndClaimTimeUpdated_ifFirstStreakDay() public {
        (uint64 claimTime, uint128 streakCount) = claimExec.usersData(beneficiary);
        assertEq(claimTime, 0, "Incorrect initial claim time");
        assertEq(streakCount, 0, "Incorrect initial streak count");
        claimExec.exposed_execute(beneficiary, enc(42));

        (claimTime, streakCount) = claimExec.usersData(beneficiary);
        assertEq(claimTime, uint64(block.timestamp), "Incorrect updated claim time");
        assertEq(streakCount, 1, "Incorrect updated streak count");
    }

    function testFuzz_StreakDayAndClaimTimeUpdated_ifNotFirstStreakDay(uint64 secondsPassed, uint128 initialStreak)
        public
    {
        vm.assume(uint256(secondsPassed) + TIME < type(uint64).max);
        vm.assume(initialStreak <= type(uint128).max - 1);
        claimExec.workaround_setUsersData(beneficiary, uint64(TIME + secondsPassed), initialStreak);

        uint256 time = TIME + secondsPassed + 1 days;
        vm.warp(time);

        claimExec.exposed_execute(beneficiary, enc(42));
        (uint64 claimTime, uint128 streakCount) = claimExec.usersData(beneficiary);
        assertEq(claimTime, uint64(time), "Incorrect updated claim time");
        assertEq(streakCount, initialStreak + 1, "Incorrect updated streak count");
    }

    function testFuzz_streakReset_ifSkippedAtLeastDay(uint64 skippedSeconds) public {
        vm.assume(skippedSeconds / 1 days > 1);
        claimExec.exposed_execute(beneficiary, enc(42));
        (, uint128 streakCount) = claimExec.usersData(beneficiary);
        assertEq(streakCount, 1, "Incorrect initial streak count");

        vm.warp(TIME + skippedSeconds);
        claimExec.exposed_execute(beneficiary, enc(42));
        (, streakCount) = claimExec.usersData(beneficiary);
        assertEq(streakCount, 1, "Incorrect updated streak count");
    }

    function testFuzz_revert_ifOnCooldown(uint24 secondsPassed) public {
        vm.assume((TIME + secondsPassed) / 1 days - TIME / 1 days < cooldownDays);
        claimExec.exposed_execute(beneficiary, enc(42));
        vm.warp(TIME + secondsPassed);
        vm.expectRevert(abi.encodeWithSelector(ClaimExecutor.RewardOnCooldown.selector, (TIME / 1 days + 1) * 1 days));
        claimExec.exposed_execute(beneficiary, enc(42));
    }

    function test_revert_ifPayloadIsZero() public {
        vm.expectRevert(abi.encodeWithSelector(IVoucherExecutor.InvalidPayload.selector));
        claimExec.exposed_execute(beneficiary, enc(0));
    }
}
