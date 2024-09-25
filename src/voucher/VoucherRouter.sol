// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {VoucherLib} from "./VoucherLib.sol";
import {IVoucher} from "../interfaces/IVoucher.sol";
import {IVoucherExecutor} from "../interfaces/IVoucherExecutor.sol";

contract VoucherRouter is IVoucher, Ownable2Step, ReentrancyGuard {
    using MessageHashUtils for bytes32;
    using ECDSA for bytes32;
    using VoucherLib for IVoucher.Voucher;

    address public defaultIssuer;
    mapping(address executor => address issuer) public executorIssuers;
    mapping(uint128 uid => bool isUsed) public usedVouchers;

    constructor(address owner, address defaultIssuer_) Ownable(owner) {
        if (defaultIssuer_ == address(0)) revert IVoucher.InvalidIssuer();
        defaultIssuer = defaultIssuer_;
    }

    function setDefaultIssuer(address issuer) external onlyOwner {
        if (issuer == address(0)) revert IVoucher.InvalidIssuer();
        defaultIssuer = issuer;
    }

    function setExecutorIssuer(address executor, address issuer) external onlyOwner {
        executorIssuers[executor] = issuer;
    }

    function use(IVoucher.Voucher[] calldata vouchers) external nonReentrant {
        if (vouchers.length == 0) {
            revert InvalidVouchersLength();
        }

        for (uint256 i = 0; i < vouchers.length; i++) {
            _validateSignature(vouchers[i]);
            _validateVoucher(vouchers[i]);
            _routeVoucher(vouchers[i]);
            emit IVoucher.Used(vouchers[i]);
        }
    }

    function _validateSignature(IVoucher.Voucher calldata voucher) internal view {
        address issuer = executorIssuers[voucher.executor];
        if (issuer == address(1)) return;

        if (issuer == address(0)) {
            issuer = defaultIssuer;
        }

        address recovered = voucher.hash().toEthSignedMessageHash().recover(voucher.signature);
        if (recovered != issuer) revert IVoucher.InvalidSignature();
    }

    function _validateVoucher(IVoucher.Voucher calldata voucher) internal view {
        if (voucher.chainId != block.chainid) revert IVoucher.InvalidChainId();
        if (voucher.router != address(this)) revert IVoucher.InvalidRouter();
        if (voucher.executor == address(0)) revert IVoucher.InvalidExecutor();
        if (block.timestamp > voucher.expireAt) {
            revert IVoucher.VoucherExpired();
        }
        if (usedVouchers[voucher.nonce]) revert IVoucher.VoucherAlreadyUsed();
    }

    function _routeVoucher(IVoucher.Voucher calldata voucher) internal {
        usedVouchers[voucher.nonce] = true;
        IVoucherExecutor(voucher.executor).execute(voucher.beneficiary, voucher.data);
    }
}
