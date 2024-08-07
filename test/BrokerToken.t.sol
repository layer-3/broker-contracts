// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BrokerToken.sol";

contract BrokerTokenTest is Test {
    BrokerToken token;
    address deployer = address(1);
    address beneficiary = address(2);

    uint8 constant DECIMALS = 8;
    uint256 constant TOKEN_SUPPLY = 10_000_000_000;

    function setUp() public {
        token = new BrokerToken(
            "Canary",
            "CANARY",
            DECIMALS,
            TOKEN_SUPPLY,
            beneficiary
        );
    }

    function test_nameAndSymbol() public view {
        assertEq(token.name(), "Canary");
        assertEq(token.symbol(), "CANARY");
    }

    function test_decimals() public view {
        assertEq(token.decimals(), DECIMALS);
    }

    function test_supplyMintedToBeneficiary() public view {
        assertEq(token.balanceOf(beneficiary), TOKEN_SUPPLY);
    }
}
