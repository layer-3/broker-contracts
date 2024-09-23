// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CostlyReceiver {
    mapping(uint256 seed => uint256 value) public costlyValues;

    receive() external payable {
        /// @dev This is a costly operation that will consume a lot of gas.
        costlyValues[block.timestamp] = 1;
    }

    fallback() external payable {
        /// @dev This is a costly operation that will consume a lot of gas.
        costlyValues[block.timestamp] = 1;
    }
}
