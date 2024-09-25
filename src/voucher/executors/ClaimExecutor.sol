// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VoucherExecutorBase} from "../VoucherExecutorBase.sol";

contract ClaimExecutor is VoucherExecutorBase {
    struct UserData {
        uint64 latestClaimTimestamp;
        uint128 streakCount;
    }

    struct DailyClaimPayload {
        uint64 points;
    }

    uint256 public constant COOLDOWN_DAYS = 1;

    mapping(address user => UserData userData) public usersData;

    /**
     * @notice Event emitted when a user claims their daily reward,
     * submitting their reward points for yesterday.
     * @param user Address of the user who claimed the reward
     * @param points Reward points submitted by the user
     * @param streakCount Current streak count of the user
     */
    event Claimed(address indexed user, uint256 points, uint128 streakCount);

    /**
     * @notice Error thrown when claiming the reward that is on cooldown
     * @param cooldownDeadline Timestamp of the end of the cooldown period
     */
    error RewardOnCooldown(uint256 cooldownDeadline);

    constructor(address router) VoucherExecutorBase(router) {}

    /**
     * @notice Internal executor function that handles both streak check-in and daily reward claim
     * @dev This function merges the logic of both streak check-ins and daily claim rewards
     * @param beneficiary The address of the user performing the check-in and claim
     * @param data The calldata for daily reward claim (contains `points`)
     */
    function _execute(address beneficiary, bytes calldata data) internal override {
        UserData storage userData = usersData[beneficiary];

        uint16 UTCDaysSinceLastUserClaim = uint16(block.timestamp / 1 days - userData.latestClaimTimestamp / 1 days);

        if (UTCDaysSinceLastUserClaim < COOLDOWN_DAYS) {
            revert RewardOnCooldown((userData.latestClaimTimestamp / 1 days + 1) * 1 days);
        }

        DailyClaimPayload memory dcp = abi.decode(data, (DailyClaimPayload));
        if (dcp.points == 0) {
            revert InvalidPayload();
        }

        if (block.timestamp / 1 days - userData.latestClaimTimestamp / 1 days == 1) {
            userData.streakCount++;
        } else {
            userData.streakCount = 1;
        }

        userData.latestClaimTimestamp = uint64(block.timestamp);

        emit Claimed(beneficiary, dcp.points, userData.streakCount);
    }
}
