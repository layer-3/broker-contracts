// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LiteStreakExecutor} from "../LiteStreakExecutor.sol";

contract TestLiteStreakExecutor is LiteStreakExecutor {
    constructor(address owner, address router) LiteStreakExecutor(owner, router) {}

    function workaround_setStreakSize(uint128 size) public {
        streakSize = size;
    }

    function workaround_setCheckinData(address user, uint128 latestCheckinDay, uint128 streakCount) public {
        _userCheckins[user] = CheckinData(latestCheckinDay, streakCount);
    }

    function exposed_execute(address beneficiary, bytes calldata data) public {
        _execute(beneficiary, data);
    }
}
