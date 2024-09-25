// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {VoucherExecutorBase} from "../VoucherExecutorBase.sol";

contract LiteStreakExecutor is VoucherExecutorBase, Ownable2Step {
    struct CheckinData {
        uint128 latestCheckinDay;
        uint128 streakCount;
    }

    mapping(address user => CheckinData userData) internal _userCheckins;

    uint128 public streakSize = 7;
    uint256 public regularPoints = 10;
    uint256 public streakPoints = 100;

    /**
     * @notice Emitted when a user checks in.
     * @param user The user that checked in.
     * @param streak The user's current streak.
     */
    event Checkin(address indexed user, uint128 streak, uint256 points);

    /**
     * @notice Error thrown when a user tries to check in while on cooldown.
     * @param availableAt The timestamp when the user can check in again.
     */
    error CheckinOnCooldown(uint256 availableAt);

    constructor(address owner, address router) Ownable(owner) VoucherExecutorBase(router) {}

    /**
     * @notice Get the check-in data for a user.
     * @param userAddress The address of the user.
     * @return checkinData The check-in data for the user.
     */
    function getCheckinData(address userAddress) public view returns (CheckinData memory) {
        return _userCheckins[userAddress];
    }

    /**
     * @notice Set the streak size, non-streak points, and streak points.
     * @dev Callable only by the owner.
     * @param streakSize_ The new streak size.
     * @param regularPoints_ The new points for non-streak days.
     * @param streakPoints_ The new points for streak days.
     */
    function setConfig(uint128 streakSize_, uint256 regularPoints_, uint256 streakPoints_) public onlyOwner {
        streakSize = streakSize_;
        regularPoints = regularPoints_;
        streakPoints = streakPoints_;
    }

    function _execute(address beneficiary, bytes calldata) internal override {
        CheckinData storage userCI = _userCheckins[beneficiary];

        if (block.timestamp / 1 days <= userCI.latestCheckinDay) {
            revert CheckinOnCooldown((block.timestamp / 1 days + 1) * 1 days);
        }

        if (block.timestamp / 1 days - userCI.latestCheckinDay == 1) {
            userCI.streakCount++;
        } else {
            /// @dev Reset streak if more than 2 days have passed
            userCI.streakCount = 1;
        }

        userCI.latestCheckinDay = uint128(block.timestamp / 1 days);

        uint256 points = regularPoints;
        uint128 streakCount = userCI.streakCount;

        if (userCI.streakCount >= streakSize) {
            points = streakPoints;
            /// @dev Reset streak if reached
            userCI.streakCount = 0;
            streakCount = streakSize;
        }

        // Emit the Checkin event with the generated random number
        emit Checkin(beneficiary, streakCount, points);
    }
}
