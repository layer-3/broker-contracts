pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BrokerTokenFactory} from "../src/BrokerTokenFactory.sol";

contract DeployBrokerTokenFactory is Script {
    function run() public {
        string memory ownerStr = vm.envString("ERC20_FACTORY_OWNER");
        address owner = vm.parseAddress(ownerStr);

        vm.startBroadcast(); // start broadcasting transactions to the blockchain
        BrokerTokenFactory factory = new BrokerTokenFactory(owner);
        vm.stopBroadcast();

        console.log("BrokerToken Factory address: %s", address(factory));
    }
}
