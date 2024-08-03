// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BrokerFactory {
    address public vaultImplementation;
    address[] public deployedBrokers;

    event BrokerCreated(address vaultAddress);

    constructor(address _vaultImplementation) {
        vaultImplementation = _vaultImplementation;
    }

    function setBrokerImplementation(address _vaultImplementation) public {
        vaultImplementation = _vaultImplementation;
    }

    function createBroker() public {
        address vault = deployClone(vaultImplementation);
        deployedBrokers.push(vault);
        emit BrokerCreated(vault);
    }

    function getDeployedBrokers() public view returns (address[] memory) {
        return deployedBrokers;
    }

    function deployClone(address implementation) internal returns (address instance) {
        bytes20 targetBytes = bytes20(implementation);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf3)
            instance := create(0, clone, 0x37)
        }
    }
}
