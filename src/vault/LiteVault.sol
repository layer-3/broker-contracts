// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// TODO:
import "../interfaces/IAuthorize.sol";
import "../interfaces/IVault.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title LiteVault
 * @notice A simple vault that allows users to deposit and withdraw tokens.
 */
// TODO: (LANG/OPT) it is better to use custom errors instead of revert strings.
contract LiteVault is IVault, ReentrancyGuard {
    // Mapping from user to token to balances
    // TODO: (STYLE) it is better to use an underscore prefix for private state variables (`_balances`).
    // Also, why don't we make it `internal`, so that it can be accessed by potential inheriting contracts?
    mapping(address => mapping(address => uint256)) private balances;

    IAuthorize public authorizer;
    // TODO: (LANG) if owner is not changed after deployment, it is better to use `immutable` modifier.
    address public owner;

    // TODO: (STYLE) it is better to declare events in the interface.
    // TODO: (STYLE) it is better to use past participle form for event names (`Deposited` and `Withdrawn`).
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
        // TODO: (RESTR) if the vault is deployed with the factory, then the owner will be granted
        // to the factory without any possibility to change it. Consider giving the owner role
        // to the parameter passed to the constructor and/or adding a function to change the owner.
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
    // TODO: (STYLE) it is better to use an underscore as a suffix (`authorizer_`) if a parameter name shadows a state variable.
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
            // TODO: (RESTR) early ERC20 tokens (e.g., USDT) do not return a boolean value from `transferFrom`, which will cause
            // the transaction to revert. Therefore, it is better to either do not check the return value or to extract it from the
            // "non-standard" ERC20 tokens.
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
            // TODO: (RESTR) the same for early ERC20 tokens.
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
