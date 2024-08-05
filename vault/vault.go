// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package vault

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// VaultMetaData contains all meta data concerning the Vault contract.
var VaultMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[],\"name\":\"ReentrancyGuardReentrantCall\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"user\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"Deposit\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"user\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"Withdrawal\",\"type\":\"event\"},{\"stateMutability\":\"payable\",\"type\":\"fallback\"},{\"inputs\":[],\"name\":\"authorizer\",\"outputs\":[{\"internalType\":\"contractIAuthorize\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"user\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"deposit\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"contractIAuthorize\",\"name\":\"_authorizer\",\"type\":\"address\"}],\"name\":\"setAuthorizer\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"withdraw\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"stateMutability\":\"payable\",\"type\":\"receive\"}]",
	Bin: "0x608060405234801561000f575f80fd5b5060015f819055503360035f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550610fb2806100645f395ff3fe608060405260043610610058575f3560e01c8063058a628f1461006157806347e7ef24146100895780638da5cb5b146100a5578063d09edf31146100cf578063f3fef3a3146100f9578063f7888aec146101215761005f565b3661005f57005b005b34801561006c575f80fd5b5061008760048036038101906100829190610a4d565b61015d565b005b6100a3600480360381019061009e9190610ad5565b61022f565b005b3480156100b0575f80fd5b506100b96104eb565b6040516100c69190610b22565b60405180910390f35b3480156100da575f80fd5b506100e3610510565b6040516100f09190610b96565b60405180910390f35b348015610104575f80fd5b5061011f600480360381019061011a9190610ad5565b610535565b005b34801561012c575f80fd5b5061014760048036038101906101429190610baf565b61090f565b6040516101549190610bfc565b60405180910390f35b60035f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16146101ec576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016101e390610c6f565b60405180910390fd5b8060025f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1603610337578034146102a4576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161029b90610cd7565b60405180910390fd5b8060015f3373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8073ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f82825461032b9190610d22565b92505081905550610482565b8173ffffffffffffffffffffffffffffffffffffffff166323b872dd3330846040518463ffffffff1660e01b815260040161037493929190610d55565b6020604051808303815f875af1158015610390573d5f803e3d5ffd5b505050506040513d601f19601f820116820180604052508101906103b49190610dbf565b6103f3576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016103ea90610e34565b60405180910390fd5b8060015f3373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f82825461047a9190610d22565b925050819055505b8173ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f5548c837ab068cf56a2c2479df0882a4922fd203edb7517321831d95078c5f62836040516104df9190610bfc565b60405180910390a35050565b60035f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60025f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b61053d610991565b5f60015f3373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20549050818110156105fc576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016105f390610e9c565b60405180910390fd5b60025f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166347c359103385856040518463ffffffff1660e01b815260040161065a93929190610d55565b602060405180830381865afa158015610675573d5f803e3d5ffd5b505050506040513d601f19601f820116820180604052508101906106999190610dbf565b6106d8576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016106cf90610f04565b60405180910390fd5b8160015f3373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f82825461075f9190610f22565b925050819055505f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff16036107e2573373ffffffffffffffffffffffffffffffffffffffff166108fc8390811502906040515f60405180830381858888f193505050501580156107dc573d5f803e3d5ffd5b5061089d565b8273ffffffffffffffffffffffffffffffffffffffff1663a9059cbb33846040518363ffffffff1660e01b815260040161081d929190610f55565b6020604051808303815f875af1158015610839573d5f803e3d5ffd5b505050506040513d601f19601f8201168201806040525081019061085d9190610dbf565b61089c576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161089390610e34565b60405180910390fd5b5b8273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f2717ead6b9200dd235aad468c9809ea400fe33ac69b5bfaa6d3e90fc922b6398846040516108fa9190610bfc565b60405180910390a35061090b6109d5565b5050565b5f60015f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2054905092915050565b60025f54036109cc576040517f3ee5aeb500000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b60025f81905550565b60015f81905550565b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f610a0b826109e2565b9050919050565b5f610a1c82610a01565b9050919050565b610a2c81610a12565b8114610a36575f80fd5b50565b5f81359050610a4781610a23565b92915050565b5f60208284031215610a6257610a616109de565b5b5f610a6f84828501610a39565b91505092915050565b610a8181610a01565b8114610a8b575f80fd5b50565b5f81359050610a9c81610a78565b92915050565b5f819050919050565b610ab481610aa2565b8114610abe575f80fd5b50565b5f81359050610acf81610aab565b92915050565b5f8060408385031215610aeb57610aea6109de565b5b5f610af885828601610a8e565b9250506020610b0985828601610ac1565b9150509250929050565b610b1c81610a01565b82525050565b5f602082019050610b355f830184610b13565b92915050565b5f819050919050565b5f610b5e610b59610b54846109e2565b610b3b565b6109e2565b9050919050565b5f610b6f82610b44565b9050919050565b5f610b8082610b65565b9050919050565b610b9081610b76565b82525050565b5f602082019050610ba95f830184610b87565b92915050565b5f8060408385031215610bc557610bc46109de565b5b5f610bd285828601610a8e565b9250506020610be385828601610a8e565b9150509250929050565b610bf681610aa2565b82525050565b5f602082019050610c0f5f830184610bed565b92915050565b5f82825260208201905092915050565b7f4e6f742074686520636f6e7472616374206f776e6572000000000000000000005f82015250565b5f610c59601683610c15565b9150610c6482610c25565b602082019050919050565b5f6020820190508181035f830152610c8681610c4d565b9050919050565b7f496e636f727265637420616d6f756e74206f66204554482073656e74000000005f82015250565b5f610cc1601c83610c15565b9150610ccc82610c8d565b602082019050919050565b5f6020820190508181035f830152610cee81610cb5565b9050919050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f610d2c82610aa2565b9150610d3783610aa2565b9250828201905080821115610d4f57610d4e610cf5565b5b92915050565b5f606082019050610d685f830186610b13565b610d756020830185610b13565b610d826040830184610bed565b949350505050565b5f8115159050919050565b610d9e81610d8a565b8114610da8575f80fd5b50565b5f81519050610db981610d95565b92915050565b5f60208284031215610dd457610dd36109de565b5b5f610de184828501610dab565b91505092915050565b7f5472616e73666572206661696c656400000000000000000000000000000000005f82015250565b5f610e1e600f83610c15565b9150610e2982610dea565b602082019050919050565b5f6020820190508181035f830152610e4b81610e12565b9050919050565b7f496e73756666696369656e742062616c616e63650000000000000000000000005f82015250565b5f610e86601483610c15565b9150610e9182610e52565b602082019050919050565b5f6020820190508181035f830152610eb381610e7a565b9050919050565b7f417574686f72697a6174696f6e206661696c65640000000000000000000000005f82015250565b5f610eee601483610c15565b9150610ef982610eba565b602082019050919050565b5f6020820190508181035f830152610f1b81610ee2565b9050919050565b5f610f2c82610aa2565b9150610f3783610aa2565b9250828203905081811115610f4f57610f4e610cf5565b5b92915050565b5f604082019050610f685f830185610b13565b610f756020830184610bed565b939250505056fea264697066735822122068ab4566c6aa3212d32bd89811031480c62d487c59127c67ae7662292cbef2ca64736f6c63430008140033",
}

// VaultABI is the input ABI used to generate the binding from.
// Deprecated: Use VaultMetaData.ABI instead.
var VaultABI = VaultMetaData.ABI

// VaultBin is the compiled bytecode used for deploying new contracts.
// Deprecated: Use VaultMetaData.Bin instead.
var VaultBin = VaultMetaData.Bin

// DeployVault deploys a new Ethereum contract, binding an instance of Vault to it.
func DeployVault(auth *bind.TransactOpts, backend bind.ContractBackend) (common.Address, *types.Transaction, *Vault, error) {
	parsed, err := VaultMetaData.GetAbi()
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	if parsed == nil {
		return common.Address{}, nil, nil, errors.New("GetABI returned nil")
	}

	address, tx, contract, err := bind.DeployContract(auth, *parsed, common.FromHex(VaultBin), backend)
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	return address, tx, &Vault{VaultCaller: VaultCaller{contract: contract}, VaultTransactor: VaultTransactor{contract: contract}, VaultFilterer: VaultFilterer{contract: contract}}, nil
}

// Vault is an auto generated Go binding around an Ethereum contract.
type Vault struct {
	VaultCaller     // Read-only binding to the contract
	VaultTransactor // Write-only binding to the contract
	VaultFilterer   // Log filterer for contract events
}

// VaultCaller is an auto generated read-only Go binding around an Ethereum contract.
type VaultCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// VaultTransactor is an auto generated write-only Go binding around an Ethereum contract.
type VaultTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// VaultFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type VaultFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// VaultSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type VaultSession struct {
	Contract     *Vault            // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// VaultCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type VaultCallerSession struct {
	Contract *VaultCaller  // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts // Call options to use throughout this session
}

// VaultTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type VaultTransactorSession struct {
	Contract     *VaultTransactor  // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// VaultRaw is an auto generated low-level Go binding around an Ethereum contract.
type VaultRaw struct {
	Contract *Vault // Generic contract binding to access the raw methods on
}

// VaultCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type VaultCallerRaw struct {
	Contract *VaultCaller // Generic read-only contract binding to access the raw methods on
}

// VaultTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type VaultTransactorRaw struct {
	Contract *VaultTransactor // Generic write-only contract binding to access the raw methods on
}

// NewVault creates a new instance of Vault, bound to a specific deployed contract.
func NewVault(address common.Address, backend bind.ContractBackend) (*Vault, error) {
	contract, err := bindVault(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &Vault{VaultCaller: VaultCaller{contract: contract}, VaultTransactor: VaultTransactor{contract: contract}, VaultFilterer: VaultFilterer{contract: contract}}, nil
}

// NewVaultCaller creates a new read-only instance of Vault, bound to a specific deployed contract.
func NewVaultCaller(address common.Address, caller bind.ContractCaller) (*VaultCaller, error) {
	contract, err := bindVault(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &VaultCaller{contract: contract}, nil
}

// NewVaultTransactor creates a new write-only instance of Vault, bound to a specific deployed contract.
func NewVaultTransactor(address common.Address, transactor bind.ContractTransactor) (*VaultTransactor, error) {
	contract, err := bindVault(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &VaultTransactor{contract: contract}, nil
}

// NewVaultFilterer creates a new log filterer instance of Vault, bound to a specific deployed contract.
func NewVaultFilterer(address common.Address, filterer bind.ContractFilterer) (*VaultFilterer, error) {
	contract, err := bindVault(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &VaultFilterer{contract: contract}, nil
}

// bindVault binds a generic wrapper to an already deployed contract.
func bindVault(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := VaultMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Vault *VaultRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Vault.Contract.VaultCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Vault *VaultRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Vault.Contract.VaultTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Vault *VaultRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Vault.Contract.VaultTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Vault *VaultCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Vault.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Vault *VaultTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Vault.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Vault *VaultTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Vault.Contract.contract.Transact(opts, method, params...)
}

// Authorizer is a free data retrieval call binding the contract method 0xd09edf31.
//
// Solidity: function authorizer() view returns(address)
func (_Vault *VaultCaller) Authorizer(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _Vault.contract.Call(opts, &out, "authorizer")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Authorizer is a free data retrieval call binding the contract method 0xd09edf31.
//
// Solidity: function authorizer() view returns(address)
func (_Vault *VaultSession) Authorizer() (common.Address, error) {
	return _Vault.Contract.Authorizer(&_Vault.CallOpts)
}

// Authorizer is a free data retrieval call binding the contract method 0xd09edf31.
//
// Solidity: function authorizer() view returns(address)
func (_Vault *VaultCallerSession) Authorizer() (common.Address, error) {
	return _Vault.Contract.Authorizer(&_Vault.CallOpts)
}

// BalanceOf is a free data retrieval call binding the contract method 0xf7888aec.
//
// Solidity: function balanceOf(address user, address token) view returns(uint256)
func (_Vault *VaultCaller) BalanceOf(opts *bind.CallOpts, user common.Address, token common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Vault.contract.Call(opts, &out, "balanceOf", user, token)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// BalanceOf is a free data retrieval call binding the contract method 0xf7888aec.
//
// Solidity: function balanceOf(address user, address token) view returns(uint256)
func (_Vault *VaultSession) BalanceOf(user common.Address, token common.Address) (*big.Int, error) {
	return _Vault.Contract.BalanceOf(&_Vault.CallOpts, user, token)
}

// BalanceOf is a free data retrieval call binding the contract method 0xf7888aec.
//
// Solidity: function balanceOf(address user, address token) view returns(uint256)
func (_Vault *VaultCallerSession) BalanceOf(user common.Address, token common.Address) (*big.Int, error) {
	return _Vault.Contract.BalanceOf(&_Vault.CallOpts, user, token)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Vault *VaultCaller) Owner(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _Vault.contract.Call(opts, &out, "owner")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Vault *VaultSession) Owner() (common.Address, error) {
	return _Vault.Contract.Owner(&_Vault.CallOpts)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Vault *VaultCallerSession) Owner() (common.Address, error) {
	return _Vault.Contract.Owner(&_Vault.CallOpts)
}

// Deposit is a paid mutator transaction binding the contract method 0x47e7ef24.
//
// Solidity: function deposit(address token, uint256 amount) payable returns()
func (_Vault *VaultTransactor) Deposit(opts *bind.TransactOpts, token common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Vault.contract.Transact(opts, "deposit", token, amount)
}

// Deposit is a paid mutator transaction binding the contract method 0x47e7ef24.
//
// Solidity: function deposit(address token, uint256 amount) payable returns()
func (_Vault *VaultSession) Deposit(token common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Vault.Contract.Deposit(&_Vault.TransactOpts, token, amount)
}

// Deposit is a paid mutator transaction binding the contract method 0x47e7ef24.
//
// Solidity: function deposit(address token, uint256 amount) payable returns()
func (_Vault *VaultTransactorSession) Deposit(token common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Vault.Contract.Deposit(&_Vault.TransactOpts, token, amount)
}

// SetAuthorizer is a paid mutator transaction binding the contract method 0x058a628f.
//
// Solidity: function setAuthorizer(address _authorizer) returns()
func (_Vault *VaultTransactor) SetAuthorizer(opts *bind.TransactOpts, _authorizer common.Address) (*types.Transaction, error) {
	return _Vault.contract.Transact(opts, "setAuthorizer", _authorizer)
}

// SetAuthorizer is a paid mutator transaction binding the contract method 0x058a628f.
//
// Solidity: function setAuthorizer(address _authorizer) returns()
func (_Vault *VaultSession) SetAuthorizer(_authorizer common.Address) (*types.Transaction, error) {
	return _Vault.Contract.SetAuthorizer(&_Vault.TransactOpts, _authorizer)
}

// SetAuthorizer is a paid mutator transaction binding the contract method 0x058a628f.
//
// Solidity: function setAuthorizer(address _authorizer) returns()
func (_Vault *VaultTransactorSession) SetAuthorizer(_authorizer common.Address) (*types.Transaction, error) {
	return _Vault.Contract.SetAuthorizer(&_Vault.TransactOpts, _authorizer)
}

// Withdraw is a paid mutator transaction binding the contract method 0xf3fef3a3.
//
// Solidity: function withdraw(address token, uint256 amount) returns()
func (_Vault *VaultTransactor) Withdraw(opts *bind.TransactOpts, token common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Vault.contract.Transact(opts, "withdraw", token, amount)
}

// Withdraw is a paid mutator transaction binding the contract method 0xf3fef3a3.
//
// Solidity: function withdraw(address token, uint256 amount) returns()
func (_Vault *VaultSession) Withdraw(token common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Vault.Contract.Withdraw(&_Vault.TransactOpts, token, amount)
}

// Withdraw is a paid mutator transaction binding the contract method 0xf3fef3a3.
//
// Solidity: function withdraw(address token, uint256 amount) returns()
func (_Vault *VaultTransactorSession) Withdraw(token common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Vault.Contract.Withdraw(&_Vault.TransactOpts, token, amount)
}

// Fallback is a paid mutator transaction binding the contract fallback function.
//
// Solidity: fallback() payable returns()
func (_Vault *VaultTransactor) Fallback(opts *bind.TransactOpts, calldata []byte) (*types.Transaction, error) {
	return _Vault.contract.RawTransact(opts, calldata)
}

// Fallback is a paid mutator transaction binding the contract fallback function.
//
// Solidity: fallback() payable returns()
func (_Vault *VaultSession) Fallback(calldata []byte) (*types.Transaction, error) {
	return _Vault.Contract.Fallback(&_Vault.TransactOpts, calldata)
}

// Fallback is a paid mutator transaction binding the contract fallback function.
//
// Solidity: fallback() payable returns()
func (_Vault *VaultTransactorSession) Fallback(calldata []byte) (*types.Transaction, error) {
	return _Vault.Contract.Fallback(&_Vault.TransactOpts, calldata)
}

// Receive is a paid mutator transaction binding the contract receive function.
//
// Solidity: receive() payable returns()
func (_Vault *VaultTransactor) Receive(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Vault.contract.RawTransact(opts, nil) // calldata is disallowed for receive function
}

// Receive is a paid mutator transaction binding the contract receive function.
//
// Solidity: receive() payable returns()
func (_Vault *VaultSession) Receive() (*types.Transaction, error) {
	return _Vault.Contract.Receive(&_Vault.TransactOpts)
}

// Receive is a paid mutator transaction binding the contract receive function.
//
// Solidity: receive() payable returns()
func (_Vault *VaultTransactorSession) Receive() (*types.Transaction, error) {
	return _Vault.Contract.Receive(&_Vault.TransactOpts)
}

// VaultDepositIterator is returned from FilterDeposit and is used to iterate over the raw logs and unpacked data for Deposit events raised by the Vault contract.
type VaultDepositIterator struct {
	Event *VaultDeposit // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *VaultDepositIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(VaultDeposit)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(VaultDeposit)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *VaultDepositIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *VaultDepositIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// VaultDeposit represents a Deposit event raised by the Vault contract.
type VaultDeposit struct {
	User   common.Address
	Token  common.Address
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterDeposit is a free log retrieval operation binding the contract event 0x5548c837ab068cf56a2c2479df0882a4922fd203edb7517321831d95078c5f62.
//
// Solidity: event Deposit(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) FilterDeposit(opts *bind.FilterOpts, user []common.Address, token []common.Address) (*VaultDepositIterator, error) {

	var userRule []interface{}
	for _, userItem := range user {
		userRule = append(userRule, userItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _Vault.contract.FilterLogs(opts, "Deposit", userRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return &VaultDepositIterator{contract: _Vault.contract, event: "Deposit", logs: logs, sub: sub}, nil
}

// WatchDeposit is a free log subscription operation binding the contract event 0x5548c837ab068cf56a2c2479df0882a4922fd203edb7517321831d95078c5f62.
//
// Solidity: event Deposit(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) WatchDeposit(opts *bind.WatchOpts, sink chan<- *VaultDeposit, user []common.Address, token []common.Address) (event.Subscription, error) {

	var userRule []interface{}
	for _, userItem := range user {
		userRule = append(userRule, userItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _Vault.contract.WatchLogs(opts, "Deposit", userRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(VaultDeposit)
				if err := _Vault.contract.UnpackLog(event, "Deposit", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseDeposit is a log parse operation binding the contract event 0x5548c837ab068cf56a2c2479df0882a4922fd203edb7517321831d95078c5f62.
//
// Solidity: event Deposit(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) ParseDeposit(log types.Log) (*VaultDeposit, error) {
	event := new(VaultDeposit)
	if err := _Vault.contract.UnpackLog(event, "Deposit", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// VaultWithdrawalIterator is returned from FilterWithdrawal and is used to iterate over the raw logs and unpacked data for Withdrawal events raised by the Vault contract.
type VaultWithdrawalIterator struct {
	Event *VaultWithdrawal // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *VaultWithdrawalIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(VaultWithdrawal)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(VaultWithdrawal)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *VaultWithdrawalIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *VaultWithdrawalIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// VaultWithdrawal represents a Withdrawal event raised by the Vault contract.
type VaultWithdrawal struct {
	User   common.Address
	Token  common.Address
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterWithdrawal is a free log retrieval operation binding the contract event 0x2717ead6b9200dd235aad468c9809ea400fe33ac69b5bfaa6d3e90fc922b6398.
//
// Solidity: event Withdrawal(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) FilterWithdrawal(opts *bind.FilterOpts, user []common.Address, token []common.Address) (*VaultWithdrawalIterator, error) {

	var userRule []interface{}
	for _, userItem := range user {
		userRule = append(userRule, userItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _Vault.contract.FilterLogs(opts, "Withdrawal", userRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return &VaultWithdrawalIterator{contract: _Vault.contract, event: "Withdrawal", logs: logs, sub: sub}, nil
}

// WatchWithdrawal is a free log subscription operation binding the contract event 0x2717ead6b9200dd235aad468c9809ea400fe33ac69b5bfaa6d3e90fc922b6398.
//
// Solidity: event Withdrawal(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) WatchWithdrawal(opts *bind.WatchOpts, sink chan<- *VaultWithdrawal, user []common.Address, token []common.Address) (event.Subscription, error) {

	var userRule []interface{}
	for _, userItem := range user {
		userRule = append(userRule, userItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _Vault.contract.WatchLogs(opts, "Withdrawal", userRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(VaultWithdrawal)
				if err := _Vault.contract.UnpackLog(event, "Withdrawal", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseWithdrawal is a log parse operation binding the contract event 0x2717ead6b9200dd235aad468c9809ea400fe33ac69b5bfaa6d3e90fc922b6398.
//
// Solidity: event Withdrawal(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) ParseWithdrawal(log types.Log) (*VaultWithdrawal, error) {
	event := new(VaultWithdrawal)
	if err := _Vault.contract.UnpackLog(event, "Withdrawal", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
