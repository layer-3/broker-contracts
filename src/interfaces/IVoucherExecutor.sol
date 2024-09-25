// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVoucherExecutor {
    error CallerIsNotRouter();

    error InvalidPayload();

    event Executed(address indexed beneficiary, bytes data);

    function execute(address beneficiary, bytes calldata data) external;
}
