// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/vault/TimeRangeAuthorizer.sol";

contract TimeRangeAuthorizerTest is Test {
    TimeRangeAuthorizer authorizer;
    address owner = address(1);
    address user = address(2);
    address token = address(3);
    uint256 amount = 100;

    uint256 startTimestamp = block.timestamp + 1000;
    uint256 endTimestamp = block.timestamp + 2000;

    function setUp() public {
        vm.startPrank(owner);
        authorizer = new TimeRangeAuthorizer(startTimestamp, endTimestamp);
        vm.stopPrank();
    }

    // TODO: test for constructor is missing

    function test_initialAuthorization() public {
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

    function test_setTimeRange() public {
        vm.startPrank(owner);
        uint256 newStartTimestamp = vm.getBlockTimestamp() + 3000;
        uint256 newEndTimestamp = vm.getBlockTimestamp() + 4000;

        authorizer.setTimeRange(newStartTimestamp, newEndTimestamp);
        vm.stopPrank();

        assertEq(authorizer.startTimestamp(), newStartTimestamp);
        assertEq(authorizer.endTimestamp(), newEndTimestamp);

        // Before newStartTimestamp
        vm.warp(newStartTimestamp - 1);
        assertEq(authorizer.authorize(user, token, amount), true);

        // At newStartTimestamp
        vm.warp(newStartTimestamp);
        assertEq(authorizer.authorize(user, token, amount), false);

        // During the new time range
        vm.warp(newStartTimestamp + 1);
        assertEq(authorizer.authorize(user, token, amount), false);

        // At newEndTimestamp
        vm.warp(newEndTimestamp);
        assertEq(authorizer.authorize(user, token, amount), false);

        // After newEndTimestamp
        vm.warp(newEndTimestamp + 1);
        assertEq(authorizer.authorize(user, token, amount), true);
    }

    function test_setTimeRangeNotOwner() public {
        vm.expectRevert("Not the contract owner");
        vm.prank(user);
        authorizer.setTimeRange(block.timestamp + 3000, block.timestamp + 4000);
    }

    function test_setTimeRangeInvalid() public {
        vm.startPrank(owner);
        uint256 newStartTimestamp = block.timestamp + 4000;
        uint256 newEndTimestamp = block.timestamp + 3000;

        vm.expectRevert("New start timestamp must be before new end timestamp");
        authorizer.setTimeRange(newStartTimestamp, newEndTimestamp);
        vm.stopPrank();
    }
}
