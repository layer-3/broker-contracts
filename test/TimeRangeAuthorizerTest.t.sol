// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TimeRangeAuthorizer.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

contract TimeRangeAuthorizerTest is Test {
    TimeRangeAuthorizer authorizer;
    address admin = address(1);
    address user = address(2);
    address token = address(3);
    uint256 amount = 100;

    uint256 startDate = block.timestamp + 1000;
    uint256 endDate = block.timestamp + 2000;

    function setUp() public {
        vm.startPrank(admin);
        authorizer = new TimeRangeAuthorizer(startDate, endDate);
        vm.stopPrank();
    }

    function test_initialAuthorization() public {
        assertEq(authorizer.authorize(user, token, amount), true);

        vm.warp(startDate);
        assertEq(authorizer.authorize(user, token, amount), false);

        vm.warp(startDate + 1);
        assertEq(authorizer.authorize(user, token, amount), false);

        vm.warp(endDate);
        assertEq(authorizer.authorize(user, token, amount), false);

        vm.warp(endDate + 1);
        assertEq(authorizer.authorize(user, token, amount), true);
    }

    function test_resetDates() public {
        vm.startPrank(admin);
        uint256 newStartDate = block.timestamp + 3000;
        uint256 newEndDate = block.timestamp + 4000;
        authorizer.resetDates(newStartDate, newEndDate);
        vm.stopPrank();

        assertEq(authorizer.startDate(), newStartDate);
        assertEq(authorizer.endDate(), newEndDate);

        assertEq(authorizer.authorize(user, token, amount), true);

        vm.warp(newStartDate);
        assertEq(authorizer.authorize(user, token, amount), false);

        vm.warp(newStartDate + 1);
        assertEq(authorizer.authorize(user, token, amount), false);

        vm.warp(newEndDate);
        assertEq(authorizer.authorize(user, token, amount), false);

        vm.warp(newEndDate + 1);
        assertEq(authorizer.authorize(user, token, amount), true);
    }

    function test_resetDatesNotAdmin() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                address(user),
                authorizer.ADMIN_ROLE()
            )
        );
        vm.prank(user);
        authorizer.resetDates(block.timestamp + 3000, block.timestamp + 4000);
    }

    function test_resetDatesInvalid() public {
        vm.startPrank(admin);
        uint256 newStartDate = block.timestamp + 4000;
        uint256 newEndDate = block.timestamp + 3000;

        vm.expectRevert("New start date must be before new end date");
        authorizer.resetDates(newStartDate, newEndDate);
        vm.stopPrank();
    }
}
