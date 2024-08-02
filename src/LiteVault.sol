// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAuthorize.sol";
import "./interfaces/IVault.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title LiteVault
 * @notice A simple vault that allows users to deposit and withdraw tokens.
 */
contract LiteVault is IVault, ReentrancyGuard {
    // Mapping from user to token to balances
    mapping(address => mapping(address => uint256)) private balances;

    IAuthorize public authorizer;
    address public owner;

    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdrawal(address indexed user, address indexed token, uint256 amount);

    /**
     * @dev Modifier to check if the caller is the owner of the contract.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    /**
     * @dev Constructor sets the initial owner of the contract.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Function to receive Ether. msg.data must be empty.
     */
    receive() external payable {}

    /**
     * @dev Fallback function is called when msg.data is not empty.
     */
    fallback() external payable {}

    /**
     * @dev Sets the authorizer contract.
     * @param _authorizer The address of the authorizer contract.
     */
    function setAuthorizer(IAuthorize _authorizer) external onlyOwner {
        authorizer = _authorizer;
    }

    /**
     * @dev Deposits tokens or ETH into the vault.
     * @param token The address of the token to deposit. Use address(0) for ETH.
     * @param amount The amount of tokens or ETH to deposit.
     */
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

    /**
     * @dev Withdraws tokens or ETH from the vault.
     * @param token The address of the token to withdraw. Use address(0) for ETH.
     * @param amount The amount of tokens or ETH to withdraw.
     */
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

    /**
     * @dev Returns the balance of the specified token for a user.
     * @param user The address of the user.
     * @param token The address of the token. Use address(0) for ETH.
     * @return The balance of the specified token for the user.
     */
    function balanceOf(address user, address token) public view override returns (uint256) {
        return balances[user][token];
    }
}
