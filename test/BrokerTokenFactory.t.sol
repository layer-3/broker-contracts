// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BrokerTokenFactory.sol";
import "../src/BrokerToken.sol";

contract BrokerTokenFactoryTest is Test {
    BrokerTokenFactory factory;
    address owner;

    function setUp() public {
        owner = address(this);
        vm.deal(owner, 100 ether);
        factory = new BrokerTokenFactory(owner);
    }

    function testCreateBrokerToken() public {
        string memory name = "BrokerToken";
        string memory symbol = "BTK";
        uint8 decimals = 8;
        uint256 supply = 1000 * 10 ** 8;

        // Ensure only the owner can create tokens
        vm.prank(owner);
        factory.createBrokerToken(name, symbol, decimals, supply);

        // Check if the token was created
        assertEq(factory.getBrokerTokensCount(), 1);

        address tokenAddress = factory.getBrokerToken(0);
        BrokerToken token = BrokerToken(tokenAddress);

        // Validate the token's properties
        assertEq(token.name(), name);
        assertEq(token.symbol(), symbol);
        assertEq(token.totalSupply(), supply);
        assertEq(token.decimals(), 8);
    }

    function testFailNonOwnerCannotCreateBrokerToken() public {
        string memory name = "BrokerToken";
        string memory symbol = "BTK";
        uint8 decimals = 8;
        uint256 supply = 1000 * 10 ** 8;

        // Try to create a token with a different address
        vm.prank(address(0x1234));
        vm.expectRevert("Ownable: caller is not the owner");
        factory.createBrokerToken(name, symbol, decimals, supply);
    }

    function testGetBrokerToken() public {
        string memory name = "BrokerToken";
        string memory symbol = "BTK";
        uint8 decimals = 8;
        uint256 supply = 1000 * 10 ** 8;

        vm.prank(owner);
        factory.createBrokerToken(name, symbol, decimals, supply);

        address tokenAddress = factory.getBrokerToken(0);
        BrokerToken token = BrokerToken(tokenAddress);

        // Validate the token address
        assertEq(address(token), tokenAddress);
    }

    function testBrokerTokensCount() public {
        string memory name1 = "BrokerToken1";
        string memory symbol1 = "BTK1";
        uint8 decimals1 = 8;
        uint256 supply1 = 1000 * 10 ** 8;

        string memory name2 = "BrokerToken2";
        string memory symbol2 = "BTK2";
        uint8 decimals2 = 8;
        uint256 supply2 = 2000 * 10 ** 8;

        vm.prank(owner);
        factory.createBrokerToken(name1, symbol1, decimals1, supply1);
        vm.prank(owner);
        factory.createBrokerToken(name2, symbol2, decimals2, supply2);

        // Validate the number of created tokens
        assertEq(factory.getBrokerTokensCount(), 2);
    }
}
