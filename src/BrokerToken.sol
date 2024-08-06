// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @notice Broker and Canary utility token is a simple ERC20 token with permit functionality.
 * All the supply is minted to the deployer.
 */
contract BrokerToken is ERC20Permit {
    uint8 private immutable _decimals;

    /**
     * @dev Simple constructor, passing arguments to ERC20Permit and ERC20 constructors.
     * Mints the supply to the deployer.
     * @param name Name of the Token.
     * @param symbol Symbol of the Token.
     * @param supply Maximum supply of the Token.
     */
    // TODO: (STYLE) no need to add an underscore suffix to the `decimals` parameter, as
    // it `decimals` does not shadow any contract state variable.
    constructor(string memory name, string memory symbol, uint8 decimals_, uint256 supply)
        ERC20Permit(name)
        ERC20(name, symbol)
    {
        _decimals = decimals_;
        // TODO: (RESTR) using `msg.sender` as a destination for minting tokens renders
        // using factory for deployment impossible, as the factory contract
        // will receive the token supply, and they will be locked there.
        // We can have a separate constructor parameter for the beneficiary.
        _mint(msg.sender, supply);
    }

    /**
     * @notice Return the number of decimals used to get its user representation.
     * @dev Overrides ERC20 default value of 18;
     * @return uint8 Number of decimals of Token.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}
