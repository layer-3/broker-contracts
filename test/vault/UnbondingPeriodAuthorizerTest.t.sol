// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, Vm} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {UnbondingPeriodAuthorizer} from "../../src/vault/UnbondingPeriodAuthorizer.sol";
import {TestERC20} from "../TestERC20.sol";
import {IAuthorize} from "../../src/interfaces/IAuthorize.sol";

uint256 constant TIME = 1716051867;

contract UnbondingPeriodAuthorizerTestBase is Test {
    UnbondingPeriodAuthorizer authorizer;
    TestERC20 token;

    address deployer = vm.createWallet("deployer").addr;
    address owner = vm.createWallet("owner").addr;
    address user = vm.createWallet("user").addr;

    uint64[] internal defaultUnbondingPeriods;

    function setUp() public virtual {
        defaultUnbondingPeriods = new uint64[](3);
        defaultUnbondingPeriods[0] = 1 days;
        defaultUnbondingPeriods[1] = 7 days;
        defaultUnbondingPeriods[2] = 30 days;

        vm.warp(TIME);

        vm.prank(deployer);
        authorizer = new UnbondingPeriodAuthorizer(owner, defaultUnbondingPeriods);

        token = new TestERC20("Test", "TST", 18, type(uint256).max);
    }
}

contract UnbondingPeriodAuthorizerTest_constructor is UnbondingPeriodAuthorizerTestBase {
    function test_constructor_setsCorrectOwner() public view {
        assertEq(authorizer.owner(), owner);
    }

    function test_constructor_setsSupportedUnbondingPeriods() public view {
        uint256[] memory periods = authorizer.getAllSupportedUnbondingPeriods();
        assertEq(periods.length, defaultUnbondingPeriods.length);

        // Check each period is in the result
        for (uint256 i = 0; i < defaultUnbondingPeriods.length; i++) {
            bool found = false;
            for (uint256 j = 0; j < periods.length; j++) {
                if (periods[j] == defaultUnbondingPeriods[i]) {
                    found = true;
                    break;
                }
            }
            assertTrue(found, "Period not found in result");
        }
    }

    function test_constructor_emitsEventsForPeriods() public {
        uint64[] memory periods = new uint64[](2);
        periods[0] = 14 days;
        periods[1] = 21 days;

        for (uint256 i = 0; i < periods.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit UnbondingPeriodAuthorizer.UnbondingPeriodStatusChanged(periods[i], true);
        }

        vm.prank(deployer);
        new UnbondingPeriodAuthorizer(owner, periods);
    }

    function test_constructor_revert_ifZeroPeriod() public {
        uint64[] memory periods = new uint64[](1);
        periods[0] = 0; // Invalid period

        vm.expectRevert(abi.encodeWithSelector(UnbondingPeriodAuthorizer.InvalidUnbondingPeriod.selector));
        vm.prank(deployer);
        new UnbondingPeriodAuthorizer(owner, periods);
    }
}

contract UnbondingPeriodAuthorizerTest_isUnbondingPeriodSupported is UnbondingPeriodAuthorizerTestBase {
    function test_isUnbondingPeriodSupported_returnsTrue_forSupportedPeriod() public view {
        assertTrue(authorizer.isUnbondingPeriodSupported(1 days));
        assertTrue(authorizer.isUnbondingPeriodSupported(7 days));
        assertTrue(authorizer.isUnbondingPeriodSupported(30 days));
    }

    function test_isUnbondingPeriodSupported_returnsFalse_forUnsupportedPeriod() public view {
        assertFalse(authorizer.isUnbondingPeriodSupported(2 days));
        assertFalse(authorizer.isUnbondingPeriodSupported(14 days));
        assertFalse(authorizer.isUnbondingPeriodSupported(0));
    }
}

contract UnbondingPeriodAuthorizerTest_getAllSupportedUnbondingPeriods is UnbondingPeriodAuthorizerTestBase {
    function test_getAllSupportedUnbondingPeriods_returnsAllPeriods() public view {
        uint256[] memory periods = authorizer.getAllSupportedUnbondingPeriods();

        assertEq(periods.length, defaultUnbondingPeriods.length);

        // Check each period is in the result
        for (uint256 i = 0; i < defaultUnbondingPeriods.length; i++) {
            bool found = false;
            for (uint256 j = 0; j < periods.length; j++) {
                if (periods[j] == defaultUnbondingPeriods[i]) {
                    found = true;
                    break;
                }
            }
            assertTrue(found, "Period not found in result");
        }
    }

    function test_getAllSupportedUnbondingPeriods_returnsEmptyArray_forNoPeriods() public {
        // Create authorizer with no periods
        uint64[] memory noPeriods = new uint64[](0);
        vm.prank(deployer);
        UnbondingPeriodAuthorizer noPeriodsAuthorizer = new UnbondingPeriodAuthorizer(owner, noPeriods);

        uint256[] memory periods = noPeriodsAuthorizer.getAllSupportedUnbondingPeriods();
        assertEq(periods.length, 0);
    }
}

contract UnbondingPeriodAuthorizerTest_getUnbondingRequest is UnbondingPeriodAuthorizerTestBase {
    function setUp() public override {
        super.setUp();

        vm.prank(user);
        authorizer.requestUnbonding(address(token), 7 days);
    }

    function test_getUnbondingRequest_returnsRequest_forExistingRequest() public view {
        (uint64 requestTimestamp, uint64 unbondingPeriod) = authorizer.getUnbondingRequest(user, address(token));

        assertEq(requestTimestamp, uint64(TIME));
        assertEq(unbondingPeriod, 7 days);
    }

    function test_getUnbondingRequest_returnsZeros_forNonExistingRequest() public view {
        (uint64 requestTimestamp, uint64 unbondingPeriod) = authorizer.getUnbondingRequest(user, address(0));

        assertEq(requestTimestamp, 0);
        assertEq(unbondingPeriod, 0);
    }
}

contract UnbondingPeriodAuthorizerTest_hasActiveUnbondingRequest is UnbondingPeriodAuthorizerTestBase {
    function setUp() public override {
        super.setUp();

        vm.prank(user);
        authorizer.requestUnbonding(address(token), 7 days);
    }

    function test_hasActiveUnbondingRequest_returnsTrue_forExistingRequest() public view {
        assertTrue(authorizer.hasActiveUnbondingRequest(user, address(token)));
    }

    function test_hasActiveUnbondingRequest_returnsFalse_forNonExistingRequest() public view {
        assertFalse(authorizer.hasActiveUnbondingRequest(user, address(0)));
        assertFalse(authorizer.hasActiveUnbondingRequest(owner, address(token)));
    }
}

contract UnbondingPeriodAuthorizerTest_setUnbondingPeriodStatus is UnbondingPeriodAuthorizerTestBase {
    function test_setUnbondingPeriodStatus_enablesNewPeriod_whenCalledByOwner() public {
        uint64 newPeriod = 14 days;

        assertFalse(authorizer.isUnbondingPeriodSupported(newPeriod));

        // Enable new period
        vm.prank(owner);
        authorizer.setUnbondingPeriodStatus(newPeriod, true);

        assertTrue(authorizer.isUnbondingPeriodSupported(newPeriod));
    }

    function test_setUnbondingPeriodStatus_disablesExistingPeriod_whenCalledByOwner() public {
        uint64 existingPeriod = 7 days;

        assertTrue(authorizer.isUnbondingPeriodSupported(existingPeriod));

        vm.prank(owner);
        authorizer.setUnbondingPeriodStatus(existingPeriod, false);

        assertFalse(authorizer.isUnbondingPeriodSupported(existingPeriod));
    }

    function test_setUnbondingPeriodStatus_emitsEvent_whenPeriodEnabled() public {
        uint64 newPeriod = 14 days;

        vm.expectEmit(true, true, true, true);
        emit UnbondingPeriodAuthorizer.UnbondingPeriodStatusChanged(newPeriod, true);

        vm.prank(owner);
        authorizer.setUnbondingPeriodStatus(newPeriod, true);
    }

    function test_setUnbondingPeriodStatus_emitsEvent_whenPeriodDisabled() public {
        uint64 existingPeriod = 7 days;

        vm.expectEmit(true, true, true, true);
        emit UnbondingPeriodAuthorizer.UnbondingPeriodStatusChanged(existingPeriod, false);

        vm.prank(owner);
        authorizer.setUnbondingPeriodStatus(existingPeriod, false);
    }

    function test_setUnbondingPeriodStatus_revert_whenPeriodIsZero() public {
        vm.expectRevert(abi.encodeWithSelector(UnbondingPeriodAuthorizer.InvalidUnbondingPeriod.selector));

        vm.prank(owner);
        authorizer.setUnbondingPeriodStatus(0, true);
    }

    function test_setUnbondingPeriodStatus_revert_whenCallerIsNotOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));

        vm.prank(user);
        authorizer.setUnbondingPeriodStatus(14 days, true);
    }
}

contract UnbondingPeriodAuthorizerTest_requestUnbonding is UnbondingPeriodAuthorizerTestBase {
    function test_requestUnbonding_createsRequest_forSupportedPeriod() public {
        vm.prank(user);
        authorizer.requestUnbonding(address(token), 7 days);

        (uint64 requestTimestamp, uint64 unbondingPeriod) = authorizer.getUnbondingRequest(user, address(token));

        assertEq(requestTimestamp, uint64(TIME));
        assertEq(unbondingPeriod, 7 days);
    }

    function test_requestUnbonding_emitsEvent() public {
        vm.expectEmit(true, true, true, true);
        emit UnbondingPeriodAuthorizer.UnbondingRequested(user, address(token), 7 days);

        vm.prank(user);
        authorizer.requestUnbonding(address(token), 7 days);
    }

    function test_requestUnbonding_revert_whenRequestAlreadyMade() public {
        // Initial request
        vm.prank(user);
        authorizer.requestUnbonding(address(token), 7 days);

        vm.warp(TIME + 1 days);

        // Request again
        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(UnbondingPeriodAuthorizer.UnbondingAlreadyRequested.selector, user, address(token))
        );
        authorizer.requestUnbonding(address(token), 7 days);
    }

    function test_requestUnbonding_revert_whenPeriodIsUnsupported() public {
        vm.expectRevert(
            abi.encodeWithSelector(UnbondingPeriodAuthorizer.UnsupportedUnbondingPeriod.selector, uint64(14 days))
        );

        vm.prank(user);
        authorizer.requestUnbonding(address(token), 14 days);
    }
}

contract UnbondingPeriodAuthorizerTest_authorize is UnbondingPeriodAuthorizerTestBase {
    uint64 unbondingPeriod = 7 days;

    function setUp() public override {
        super.setUp();

        vm.prank(user);
        authorizer.requestUnbonding(address(token), unbondingPeriod);
    }

    function test_authorize_returnsTrue_whenUnbondingPeriodExpired() public {
        vm.warp(TIME + unbondingPeriod + 1);

        bool authorized = authorizer.authorize(user, address(token), 100);

        assertTrue(authorized);
    }

    function test_authorize_deletesRequest_whenAuthorized() public {
        vm.warp(TIME + unbondingPeriod + 1);

        bool authorized = authorizer.authorize(user, address(token), 100);

        assertTrue(authorized);
        assertFalse(authorizer.hasActiveUnbondingRequest(user, address(token)));
    }

    function test_authorize_emitsEvent_whenAuthorized() public {
        vm.warp(TIME + unbondingPeriod + 1);

        vm.expectEmit(true, true, true, true);
        emit UnbondingPeriodAuthorizer.UnbondingCompleted(user, address(token));

        authorizer.authorize(user, address(token), 100);
    }

    function test_authorize_revert_whenUnbondingPeriodNotExpired() public {
        vm.warp(TIME + unbondingPeriod - 1 hours);

        vm.expectRevert(
            abi.encodeWithSelector(
                UnbondingPeriodAuthorizer.UnbondingPeriodNotExpired.selector,
                uint64(TIME),
                uint64(TIME + unbondingPeriod - 1 hours),
                uint64(unbondingPeriod)
            )
        );

        authorizer.authorize(user, address(token), 100);
    }

    function test_authorize_revert_whenNoRequestExists() public {
        vm.expectRevert(
            abi.encodeWithSelector(UnbondingPeriodAuthorizer.UnbondingNotRequested.selector, user, address(0))
        );

        authorizer.authorize(user, address(0), 100);
    }
}
