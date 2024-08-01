// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAuthorize.sol";
import "./interfaces/IVault.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract Vault is IVault, ReentrancyGuard, AccessControl {
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    // Mapping from user to token to balances using EnumerableMap
    mapping(address => EnumerableMap.AddressToUintMap) private balances;

    IAuthorize public authorizer;
    address public owner;

    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdrawal(address indexed user, address indexed token, uint256 amount);

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    receive() external payable {}

    fallback() external payable {}

    function setAuthorizer(IAuthorize _authorizer) external onlyRole(ADMIN_ROLE) {
        authorizer = _authorizer;
    }

    function deposit(address token, uint256 amount) external payable override {
        if (token == address(0)) {
            require(msg.value == amount, "Incorrect amount of ETH sent");
            if (balances[msg.sender].contains(address(0))) {
                balances[msg.sender].set(address(0), balances[msg.sender].get(address(0)) + amount);
            } else {
                balances[msg.sender].set(address(0), amount);
            }
        } else {
            require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");
            if (balances[msg.sender].contains(token)) {
                balances[msg.sender].set(token, balances[msg.sender].get(token) + amount);
            } else {
                balances[msg.sender].set(token, amount);
            }
        }
        emit Deposit(msg.sender, token, amount);
    }

    function withdraw(address token, uint256 amount) external override nonReentrant {
        uint256 currentBalance = balances[msg.sender].contains(token) ? balances[msg.sender].get(token) : 0;
        require(currentBalance >= amount, "Insufficient balance");
        require(authorizer.authorize(msg.sender, token, amount), "Authorization failed");

        if (balances[msg.sender].get(token) == amount) {
            balances[msg.sender].remove(token);
        } else {
            balances[msg.sender].set(token, balances[msg.sender].get(token) - amount);
        }

        if (token == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
        }
        emit Withdrawal(msg.sender, token, amount);
    }

    function balanceOf(address user, address token) public view override returns (uint256) {
        return balances[user].contains(token) ? balances[user].get(token) : 0;
    }
}
