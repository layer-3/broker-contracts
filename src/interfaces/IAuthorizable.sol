// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IAuthorize} from "./IAuthorize.sol";

/**
 * @title IAuthorizable
 * @notice Interface for a contract that is using Authorize logic.
 */
interface IAuthorizable {
    /**
     * @notice Emitted when the authorizer contract is changed.
     * @param newAuthorizer The address of the new authorizer contract.
     */
    event AuthorizerChanged(IAuthorize indexed newAuthorizer);

    /**
     * @dev Sets the authorizer contract.
     * @param newAuthorizer The address of the authorizer contract.
     */
    function setAuthorizer(IAuthorize newAuthorizer) external;
}
