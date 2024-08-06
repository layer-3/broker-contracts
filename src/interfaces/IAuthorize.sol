// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IAuthorize
 * @notice Interface for an authorization contract that validates if certain actions are allowed.
 */
interface IAuthorize {
    /**
     * @dev Authorizes actions based on the owner, token, and amount.
     * @param owner The address of the token owner.
     * @param token The address of the token.
     * @param amount The amount of tokens to be authorized.
     * @return True if the action is authorized, false otherwise.
     */
    // TODO: (RESTR) maybe it is better to pass `bytes calldata data` instead of specific parameters, as
    // specified parameters may not be enough for some authorization checks. Moreover, using a flexible data
    // parameter will allow an Authorizer and its users to evolve without changing the interface.
    function authorize(address owner, address token, uint256 amount) external view returns (bool);
}
