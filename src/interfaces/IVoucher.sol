// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVoucher {
    error InvalidIssuer();
    error InvalidSignature();
    error InvalidChainId();
    error InvalidRouter();
    error InvalidExecutor();
    error VoucherExpired();
    error VoucherAlreadyUsed();
    error InvalidVouchersLength();

    event Used(IVoucher.Voucher voucher);

    struct Voucher {
        uint32 chainId;
        address router;
        address executor;
        address beneficiary;
        uint64 expireAt;
        uint128 nonce;
        bytes data;
        bytes signature;
    }

    function use(IVoucher.Voucher[] calldata vouchers) external;
}
