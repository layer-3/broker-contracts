// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAuthorizeV2} from "./IAuthorizeV2.sol";

/**
 * @title IAuthorizable
 * @notice Interface for a contract that is using Authorize logic.
 */
interface IAuthorizableV2 {
    /**
     * @notice Emitted when the authorizer contract is changed.
     * @param newAuthorizer The address of the new authorizer contract.
     */
    event AuthorizerChanged(IAuthorizeV2 indexed newAuthorizer);

    /**
     * @dev Sets the authorizer contract.
     * @param newAuthorizer The address of the authorizer contract.
     */
    function setAuthorizer(IAuthorizeV2 newAuthorizer) external;
}
