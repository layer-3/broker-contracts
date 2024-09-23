// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {BrokerToken} from "../src/BrokerToken.sol";

contract BrokerTokenTest is Test {
    BrokerToken token;
    address deployer = address(1);
    address beneficiary = address(2);

    uint8 constant DECIMALS = 8;
    uint256 constant TOKEN_SUPPLY = 10_000_000_000;

    function setUp() public {
        token = new BrokerToken("Canary", "CANARY", DECIMALS, TOKEN_SUPPLY, beneficiary);
    }

    function test_constructor_revert_ifBeneficiaryIsZero() public {
        vm.expectRevert(abi.encodeWithSelector(BrokerToken.InvalidAddress.selector));
        new BrokerToken("Canary", "CANARY", DECIMALS, TOKEN_SUPPLY, address(0));
    }

    function tes_constructort_nameAndSymbol() public view {
        assertEq(token.name(), "Canary");
        assertEq(token.symbol(), "CANARY");
    }

    function test_constructor_decimals() public view {
        assertEq(token.decimals(), DECIMALS);
    }

    function test_constructor_supplyMintedToBeneficiary() public view {
        assertEq(token.balanceOf(beneficiary), TOKEN_SUPPLY);
    }
}
