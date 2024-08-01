// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import '@openzeppelin/contracts/access/Ownable.sol';
import './BrokerToken.sol';

/**
 * @title BrokerTokenFactory
 * @notice Factory contract to create new instances of BrokerToken.
 * Only the owner can create new tokens.
 */
contract BrokerTokenFactory is Ownable {
    // Array to store addresses of created tokens
    address[] public brokerTokens;

    /**
     * @notice Event emitted when a new BrokerToken is created.
     * @param tokenAddress Address of the newly created BrokerToken.
     */
    event BrokerTokenCreated(address indexed tokenAddress);

    constructor(address owner) Ownable(owner) {}

    /**
     * @notice Creates a new BrokerToken and mints the supply to the factory owner.
     * @param name Name of the Token.
     * @param symbol Symbol of the Token.
     * @param supply Maximum supply of the Token.
     */
    function createBrokerToken(
        string memory name,
        string memory symbol,
        uint256 supply
    ) external onlyOwner {
        BrokerToken token = new BrokerToken(name, symbol, supply);
        brokerTokens.push(address(token));
        emit BrokerTokenCreated(address(token));
    }

    /**
     * @notice Returns the number of created BrokerTokens.
     * @return uint256 Number of created BrokerTokens.
     */
    function getBrokerTokensCount() external view returns (uint256) {
        return brokerTokens.length;
    }

    /**
     * @notice Returns the address of a created BrokerToken at a given index.
     * @param index Index of the token in the brokerTokens array.
     * @return address Address of the BrokerToken.
     */
    function getBrokerToken(uint256 index) external view returns (address) {
        require(index < brokerTokens.length, "Index out of bounds");
        return brokerTokens[index];
    }
}

