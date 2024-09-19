// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAuthorize} from "../../interfaces/IAuthorize.sol";
import {LiteVault} from "../LiteVault.sol";

contract TestLiteVault is LiteVault {
    constructor(address owner, IAuthorize authorizer_) LiteVault(owner, authorizer_) {}

    function workaround_setBalance(address user, address token, uint256 amount) external {
        _balances[user][token] = amount;
    }

    function exposed_isWithdrawalGracePeriodActive(
        uint64 latestSetAuthorizerTimestamp_,
        uint64 now_,
        uint64 gracePeriod
    ) external pure returns (bool) {
        return _isWithdrawalGracePeriodActive(latestSetAuthorizerTimestamp_, now_, gracePeriod);
    }
}
