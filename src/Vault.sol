// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAuthorize.sol";
import "./interfaces/IVault.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Vault is IVault, ReentrancyGuard {
    // Mapping from user to token to balances
    mapping(address => mapping(address => uint256)) private balances;

    IAuthorize public authorizer;
    address public owner;

    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdrawal(address indexed user, address indexed token, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    fallback() external payable {}

    function setAuthorizer(IAuthorize _authorizer) external onlyOwner {
        authorizer = _authorizer;
    }

    function deposit(address token, uint256 amount) public payable override {
        if (token == address(0)) {
            require(msg.value == amount, "Incorrect amount of ETH sent");
            balances[msg.sender][address(0)] += amount;
        } else {
            require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");
            balances[msg.sender][token] += amount;
        }
        emit Deposit(msg.sender, token, amount);
    }

    function withdraw(address token, uint256 amount) external override nonReentrant {
        uint256 currentBalance = balances[msg.sender][token];
        require(currentBalance >= amount, "Insufficient balance");
        require(authorizer.authorize(msg.sender, token, amount), "Authorization failed");

        balances[msg.sender][token] -= amount;

        if (token == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
        }
        emit Withdrawal(msg.sender, token, amount);
    }

    function balanceOf(address user, address token) public view override returns (uint256) {
        return balances[user][token];
    }
}
