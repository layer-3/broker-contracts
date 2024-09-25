// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ClaimExecutor} from "../ClaimExecutor.sol";

contract TestClaimExecutor is ClaimExecutor {
    constructor(address router) ClaimExecutor(router) {}

    function workaround_setUsersData(address user, uint64 latestClaimTimestamp, uint128 streakCount) public {
        usersData[user] = UserData(latestClaimTimestamp, streakCount);
    }

    function exposed_execute(address beneficiary, bytes calldata data) public {
        _execute(beneficiary, data);
    }
}
