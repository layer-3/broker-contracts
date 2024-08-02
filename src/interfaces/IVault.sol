// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IVault
 * @notice Interface for a vault contract that allows users to deposit, withdraw, and check balances of tokens and ETH.
 */
interface IVault {

    /**
     * @dev Deposits a specified amount of tokens or ETH into the vault.
     * @param token The address of the token to deposit. Use address(0) for ETH.
     * @param amount The amount of tokens or ETH to deposit.
     */
    function deposit(address token, uint256 amount) external payable;

    /**
     * @dev Withdraws a specified amount of tokens or ETH from the vault.
     * @param token The address of the token to withdraw. Use address(0) for ETH.
     * @param amount The amount of tokens or ETH to withdraw.
     */
    function withdraw(address token, uint256 amount) external;

    /**
     * @dev Returns the balance of a specified token for a user.
     * @param user The address of the user.
     * @param token The address of the token. Use address(0) for ETH.
     * @return The balance of the specified token for the user.
     */
    function balanceOf(address user, address token) external view returns (uint256);
}
