// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IVoucher} from "../interfaces/IVoucher.sol";

library VoucherLib {
    function pack(IVoucher.Voucher memory voucher) internal pure returns (bytes memory) {
        return abi.encode(
            voucher.chainId,
            voucher.router,
            voucher.executor,
            voucher.beneficiary,
            voucher.expireAt,
            voucher.nonce,
            voucher.data
        );
    }

    function hash(IVoucher.Voucher memory voucher) internal pure returns (bytes32) {
        return keccak256(pack(voucher));
    }
}
