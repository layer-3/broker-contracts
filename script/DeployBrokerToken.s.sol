// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BrokerToken} from "../src/BrokerToken.sol";

contract DeployBrokerToken is Script {
    error EmptyName();
    error EmptySymbol();
    error EmptyDecimals();
    error EmptySupply();
    error EmptyBeneficiary();

    function run() public {
        (string memory name, string memory symbol, uint8 decimals, uint256 supply, address beneficiary) = getParams();

        vm.startBroadcast(); // start broadcasting transactions to the blockchain
        BrokerToken token = new BrokerToken(name, symbol, decimals, supply, beneficiary);
        vm.stopBroadcast();

        console.log("BrokerToken address: %s", address(token));
    }

    function getParams()
        public
        view
        returns (string memory name, string memory symbol, uint8 decimals, uint256 supply, address beneficiary)
    {
        name = vm.envString("BROKER_TOKEN_NAME");
        if (compareStrings(name, "")) {
            revert EmptyName();
        }

        symbol = vm.envString("BROKER_TOKEN_SYMBOL");
        if (compareStrings(symbol, "")) {
            revert EmptySymbol();
        }

        string memory decimalsStr = vm.envString("BROKER_TOKEN_DECIMALS");
        decimals = uint8(vm.parseUint(decimalsStr));
        if (decimals == 0) {
            revert EmptyDecimals();
        }

        string memory supplyStr = vm.envString("BROKER_TOKEN_SUPPLY");
        supply = uint256(vm.parseUint(supplyStr));
        if (supply == 0) {
            revert EmptySupply();
        }

        string memory beneficiaryStr = vm.envString("BROKER_TOKEN_BENEFICIARY");
        beneficiary = address(vm.parseAddress(beneficiaryStr));
        if (beneficiary == address(0)) {
            revert EmptyBeneficiary();
        }
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
