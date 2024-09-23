// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @notice Broker and Canary utility token is a simple ERC20 token with permit functionality.
 * All the supply is minted to the deployer.
 */
contract BrokerToken is ERC20Permit {
    uint8 private immutable _decimals;

    /**
     * @notice Error thrown when the address supplied with the function call is invalid.
     */
    error InvalidAddress();

    /**
     * @dev Simple constructor, passing arguments to ERC20Permit and ERC20 constructors.
     * Mints the supply to the deployer.
     * @param name Name of the Token.
     * @param symbol Symbol of the Token.
     * @param decimals_ Number of decimals of the Token.
     * @param supply Maximum supply of the Token.
     */
    constructor(string memory name, string memory symbol, uint8 decimals_, uint256 supply, address beneficiary)
        ERC20Permit(name)
        ERC20(name, symbol)
    {
        if (beneficiary == address(0)) {
            revert InvalidAddress();
        }

        _decimals = decimals_;
        _mint(beneficiary, supply);
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
