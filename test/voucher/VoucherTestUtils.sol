// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {Test, Vm} from "forge-std/Test.sol";

import {VoucherLib} from "../../src/voucher/VoucherLib.sol";
import {IVoucher} from "../../src/interfaces/IVoucher.sol";

contract VoucherTestUtils is Test {
    using VoucherLib for IVoucher.Voucher;

    uint256 public randNonce;
    uint64 voucherLifeTime;

    constructor(uint64 voucherLifeTime_) {
        voucherLifeTime = voucherLifeTime_;
    }

    function signEthMessage(Vm vm, uint256 key, bytes memory encoded) internal pure returns (bytes memory signature) {
        bytes32 messageHash = keccak256(encoded);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, MessageHashUtils.toEthSignedMessageHash(messageHash));
        signature = abi.encodePacked(r, s, v);
    }

    function signVoucher(IVoucher.Voucher memory v, Vm.Wallet memory wallet)
        public
        pure
        returns (IVoucher.Voucher memory)
    {
        v.signature = signEthMessage(vm, wallet.privateKey, v.pack());
        return v;
    }

    function signVouchers(IVoucher.Voucher[] memory vouchers, Vm.Wallet memory wallet)
        public
        pure
        returns (IVoucher.Voucher[] memory)
    {
        for (uint256 i = 0; i < vouchers.length; i++) {
            vouchers[i] = signVoucher(vouchers[i], wallet);
        }
        return vouchers;
    }

    function renewVoucher(IVoucher.Voucher memory v) public returns (IVoucher.Voucher memory) {
        v.expireAt = uint64(block.timestamp) + voucherLifeTime;
        v.nonce = uint128(uint256(keccak256(abi.encode(block.timestamp + randNonce++))));
        return v;
    }

    function renewVoucherWith(IVoucher.Voucher memory v, address beneficiary, bytes memory data)
        public
        returns (IVoucher.Voucher memory)
    {
        IVoucher.Voucher memory v_ = renewVoucher(v);
        v_.beneficiary = beneficiary;
        v_.data = data;
        return v_;
    }
}
