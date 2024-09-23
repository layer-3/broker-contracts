// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, Vm} from "forge-std/Test.sol";

import {TimeRangeAuthorizer} from "../../src/vault/TimeRangeAuthorizer.sol";

contract TimeRangeAuthorizerTest is Test {
    TimeRangeAuthorizer authorizer;
    address deployer = address(1);
    address user = address(2);
    address token = address(3);
    uint256 amount = 100;

    uint256 startTimestamp = block.timestamp + 1000;
    uint256 endTimestamp = block.timestamp + 2000;

    function setUp() public {
        vm.startPrank(deployer);
        authorizer = new TimeRangeAuthorizer(startTimestamp, endTimestamp);
        vm.stopPrank();
    }

    function test_constructor() public view {
        assertEq(authorizer.startTimestamp(), startTimestamp);
        assertEq(authorizer.endTimestamp(), endTimestamp);
    }

    function test_constructor_reverts_ifInvalidTimeRange() public {
        vm.expectRevert(
            abi.encodeWithSelector(TimeRangeAuthorizer.InvalidTimeRange.selector, endTimestamp, startTimestamp)
        );
        new TimeRangeAuthorizer(endTimestamp, startTimestamp);
    }

    function test_correctAuth_relariveToTimeRange() public {
        assertEq(authorizer.authorize(user, token, amount), true);

        vm.warp(startTimestamp);
        assertEq(authorizer.authorize(user, token, amount), false);

        vm.warp(startTimestamp + 1);
        assertEq(authorizer.authorize(user, token, amount), false);

        vm.warp(endTimestamp);
        assertEq(authorizer.authorize(user, token, amount), false);

        vm.warp(endTimestamp + 1);
        assertEq(authorizer.authorize(user, token, amount), true);
    }
}
