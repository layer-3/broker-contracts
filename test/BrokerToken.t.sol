// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BrokerToken.sol";

contract BrokerTokenTest is Test {
    BrokerToken token;
    address deployer;

    uint8 constant DECIMALS = 8;
    uint256 constant TOKEN_SUPPLY = 10_000_000_000;

    function setUp() public {
        deployer = address(this); // Use the test contract address as the deployer
        token = new BrokerToken("Canary", "CANARY", DECIMALS, TOKEN_SUPPLY);
    }

    // TODO: (STYLE) test name should be separated by undescore (e.g., `test_nameAndSymbol`)
    function testNameAndSymbol() public view {
        assertEq(token.name(), "Canary");
        assertEq(token.symbol(), "CANARY");
    }

    function testDecimals() public view {
        assertEq(token.decimals(), DECIMALS);
    }

    function testSupplyMintedToDeployer() public view {
        assertEq(token.balanceOf(deployer), TOKEN_SUPPLY);
    }
}
