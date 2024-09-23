// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VoucherRouter} from "../VoucherRouter.sol";
import {IVoucher} from "../../interfaces/IVoucher.sol";

contract TestVoucherRouter is VoucherRouter {
    constructor(address owner, address defaultIssuer_) VoucherRouter(owner, defaultIssuer_) {}

    function workaround_setVoucherUsed(uint128 nonce, bool used) external {
        usedVouchers[nonce] = used;
    }

    function workaround_setDefaultIssuer(address issuer) external {
        defaultIssuer = issuer;
    }

    function workaround_setExecutorIssuer(address executor, address issuer) external {
        executorIssuers[executor] = issuer;
    }

    function exposed_validateSignature(IVoucher.Voucher calldata voucher) external view {
        _validateSignature(voucher);
    }

    function exposed_validateVoucher(IVoucher.Voucher calldata voucher) external view {
        _validateVoucher(voucher);
    }

    function exposed_routeVoucher(IVoucher.Voucher calldata voucher) external {
        _routeVoucher(voucher);
    }
}
