// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";

import {IAuthorizeV2} from "../interfaces/IAuthorizeV2.sol";
import {ITradingVault, ITradingStructs} from "../interfaces/ITradingVault.sol";

contract TradingVaultAuthorizer is IAuthorizeV2 {
    using MessageHashUtils for bytes32;
    using ECDSA for bytes32;

    error InvalidSignature();

    address public immutable broker;

    constructor(address broker_) {
        broker = broker_;
    }

    function authorize(bytes calldata authData) external view returns (bool) {
        bytes8 mode = bytes8(authData[:8]);
        bytes memory authData_ = authData[8:];
        bytes memory data;
        bytes memory signature;

        if (mode == ITradingVault.withdraw.selector) {
            ITradingStructs.Intent memory intent;
            (intent, signature) = abi.decode(authData_, (ITradingStructs.Intent, bytes));
            data = abi.encode(intent);
        } else if (mode == ITradingVault.settle.selector) {
            ITradingStructs.Outcome memory outcome;
            (outcome, signature) = abi.decode(authData_, (ITradingStructs.Outcome, bytes));
            data = abi.encode(outcome, ITradingVault.settle.selector);
        } else if (mode == ITradingVault.liquidate.selector) {
            ITradingStructs.Outcome memory outcome;
            (outcome, signature) = abi.decode(authData_, (ITradingStructs.Outcome, bytes));
            data = abi.encode(outcome, ITradingVault.liquidate.selector);
        } else {
            revert IAuthorizeV2.Unauthorized(authData);
        }

        _requireValidSigner(broker, data, signature);
        return true;
    }

    function _requireValidSigner(address expectedSigner, bytes memory message, bytes memory sig) internal view {
        bytes32 hash = keccak256(message);
        if (expectedSigner.code.length == 0) {
            address recovered = hash.toEthSignedMessageHash().recover(sig);
            require(recovered == expectedSigner, InvalidSignature());
        } else {
            bytes4 value = IERC1271(expectedSigner).isValidSignature(hash, sig);
            require(value == IERC1271.isValidSignature.selector, InvalidSignature());
        }
    }
}
