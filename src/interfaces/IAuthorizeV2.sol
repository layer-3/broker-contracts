// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IAuthorize
 * @notice Interface for an authorization contract that validates if certain actions are allowed.
 */
interface IAuthorizeV2 {
    error Unauthorized(bytes authData);

    function authorize(bytes calldata authData) external view returns (bool);
}
