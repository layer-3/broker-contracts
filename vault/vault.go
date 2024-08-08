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
	ABI: "[{\"inputs\":[{\"internalType\":\"address\",\"name\":\"owner_\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"target\",\"type\":\"address\"}],\"name\":\"AddressEmptyCode\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"AddressInsufficientBalance\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"FailedInnerCall\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"IncorrectValue\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"required\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"available\",\"type\":\"uint256\"}],\"name\":\"InsufficientBalance\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"NotOwner\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"ReentrancyGuardReentrantCall\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"}],\"name\":\"SafeERC20FailedOperation\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"user\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"Unauthorized\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"user\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"Deposited\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"user\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"Withdrawn\",\"type\":\"event\"},{\"stateMutability\":\"payable\",\"type\":\"fallback\"},{\"inputs\":[],\"name\":\"authorizer\",\"outputs\":[{\"internalType\":\"contractIAuthorize\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"user\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"deposit\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"contractIAuthorize\",\"name\":\"newAuthorizer\",\"type\":\"address\"}],\"name\":\"setAuthorizer\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"withdraw\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"stateMutability\":\"payable\",\"type\":\"receive\"}]",
	Bin: "0x60a060405234801562000010575f80fd5b50604051620011e1380380620011e18339818101604052810190620000369190620000dd565b60015f819055508073ffffffffffffffffffffffffffffffffffffffff1660808173ffffffffffffffffffffffffffffffffffffffff1681525050506200010d565b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f620000a7826200007c565b9050919050565b620000b9816200009b565b8114620000c4575f80fd5b50565b5f81519050620000d781620000ae565b92915050565b5f60208284031215620000f557620000f462000078565b5b5f6200010484828501620000c7565b91505092915050565b6080516110b46200012d5f395f818161015f015261048f01526110b45ff3fe608060405260043610610058575f3560e01c8063058a628f1461006157806347e7ef24146100895780638da5cb5b146100a5578063d09edf31146100cf578063f3fef3a3146100f9578063f7888aec146101215761005f565b3661005f57005b005b34801561006c575f80fd5b5061008760048036038101906100829190610cb0565b61015d565b005b6100a3600480360381019061009e9190610d38565b610230565b005b3480156100b0575f80fd5b506100b961048d565b6040516100c69190610d85565b60405180910390f35b3480156100da575f80fd5b506100e36104b1565b6040516100f09190610df9565b60405180910390f35b348015610104575f80fd5b5061011f600480360381019061011a9190610d38565b6104d6565b005b34801561012c575f80fd5b5061014760048036038101906101429190610e12565b61082d565b6040516101549190610e5f565b60405180910390f35b7f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16146101ed57336040517f245aecd30000000000000000000000000000000000000000000000000000000081526004016101e49190610d85565b60405180910390fd5b8060025f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff160361032f5780341461029c576040517fd2ade55600000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b8060015f3373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8073ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8282546103239190610ea5565b92505081905550610424565b5f3414610368576040517fd2ade55600000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6103953330838573ffffffffffffffffffffffffffffffffffffffff166108af909392919063ffffffff16565b8060015f3373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f82825461041c9190610ea5565b925050819055505b8173ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8752a472e571a816aea92eec8dae9baf628e840f4929fbcc2d155e6233ff68a7836040516104819190610e5f565b60405180910390a35050565b7f000000000000000000000000000000000000000000000000000000000000000081565b60025f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6104de610931565b5f60015f3373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20549050818110156105a3578282826040517fdb42144d00000000000000000000000000000000000000000000000000000000815260040161059a93929190610ed8565b60405180910390fd5b60025f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166347c359103385856040518463ffffffff1660e01b815260040161060193929190610f0d565b602060405180830381865afa15801561061c573d5f803e3d5ffd5b505050506040513d601f19601f820116820180604052508101906106409190610f77565b610685573383836040517f431ef61600000000000000000000000000000000000000000000000000000000815260040161067c93929190610f0d565b60405180910390fd5b8160015f3373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f82825461070c9190610fa2565b925050819055505f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff160361078f573373ffffffffffffffffffffffffffffffffffffffff166108fc8390811502906040515f60405180830381858888f19350505050158015610789573d5f803e3d5ffd5b506107bb565b6107ba33838573ffffffffffffffffffffffffffffffffffffffff166109759092919063ffffffff16565b5b8273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167fd1c19fbcd4551a5edfb66d43d2e337c04837afda3482b42bdf569a8fccdae5fb846040516108189190610e5f565b60405180910390a3506108296109f4565b5050565b5f60015f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2054905092915050565b61092b848573ffffffffffffffffffffffffffffffffffffffff166323b872dd8686866040516024016108e493929190610f0d565b604051602081830303815290604052915060e01b6020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff83818316178352505050506109fd565b50505050565b60025f540361096c576040517f3ee5aeb500000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b60025f81905550565b6109ef838473ffffffffffffffffffffffffffffffffffffffff1663a9059cbb85856040516024016109a8929190610fd5565b604051602081830303815290604052915060e01b6020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff83818316178352505050506109fd565b505050565b60015f81905550565b5f610a27828473ffffffffffffffffffffffffffffffffffffffff16610a9290919063ffffffff16565b90505f815114158015610a4b575080806020019051810190610a499190610f77565b155b15610a8d57826040517f5274afe7000000000000000000000000000000000000000000000000000000008152600401610a849190610d85565b60405180910390fd5b505050565b6060610a9f83835f610aa7565b905092915050565b606081471015610aee57306040517fcd786059000000000000000000000000000000000000000000000000000000008152600401610ae59190610d85565b60405180910390fd5b5f808573ffffffffffffffffffffffffffffffffffffffff168486604051610b169190611068565b5f6040518083038185875af1925050503d805f8114610b50576040519150601f19603f3d011682016040523d82523d5f602084013e610b55565b606091505b5091509150610b65868383610b70565b925050509392505050565b606082610b8557610b8082610bfd565b610bf5565b5f8251148015610bab57505f8473ffffffffffffffffffffffffffffffffffffffff163b145b15610bed57836040517f9996b315000000000000000000000000000000000000000000000000000000008152600401610be49190610d85565b60405180910390fd5b819050610bf6565b5b9392505050565b5f81511115610c0f5780518082602001fd5b6040517f1425ea4200000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f610c6e82610c45565b9050919050565b5f610c7f82610c64565b9050919050565b610c8f81610c75565b8114610c99575f80fd5b50565b5f81359050610caa81610c86565b92915050565b5f60208284031215610cc557610cc4610c41565b5b5f610cd284828501610c9c565b91505092915050565b610ce481610c64565b8114610cee575f80fd5b50565b5f81359050610cff81610cdb565b92915050565b5f819050919050565b610d1781610d05565b8114610d21575f80fd5b50565b5f81359050610d3281610d0e565b92915050565b5f8060408385031215610d4e57610d4d610c41565b5b5f610d5b85828601610cf1565b9250506020610d6c85828601610d24565b9150509250929050565b610d7f81610c64565b82525050565b5f602082019050610d985f830184610d76565b92915050565b5f819050919050565b5f610dc1610dbc610db784610c45565b610d9e565b610c45565b9050919050565b5f610dd282610da7565b9050919050565b5f610de382610dc8565b9050919050565b610df381610dd9565b82525050565b5f602082019050610e0c5f830184610dea565b92915050565b5f8060408385031215610e2857610e27610c41565b5b5f610e3585828601610cf1565b9250506020610e4685828601610cf1565b9150509250929050565b610e5981610d05565b82525050565b5f602082019050610e725f830184610e50565b92915050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f610eaf82610d05565b9150610eba83610d05565b9250828201905080821115610ed257610ed1610e78565b5b92915050565b5f606082019050610eeb5f830186610d76565b610ef86020830185610e50565b610f056040830184610e50565b949350505050565b5f606082019050610f205f830186610d76565b610f2d6020830185610d76565b610f3a6040830184610e50565b949350505050565b5f8115159050919050565b610f5681610f42565b8114610f60575f80fd5b50565b5f81519050610f7181610f4d565b92915050565b5f60208284031215610f8c57610f8b610c41565b5b5f610f9984828501610f63565b91505092915050565b5f610fac82610d05565b9150610fb783610d05565b9250828203905081811115610fcf57610fce610e78565b5b92915050565b5f604082019050610fe85f830185610d76565b610ff56020830184610e50565b9392505050565b5f81519050919050565b5f81905092915050565b5f5b8381101561102d578082015181840152602081019050611012565b5f8484015250505050565b5f61104282610ffc565b61104c8185611006565b935061105c818560208601611010565b80840191505092915050565b5f6110738284611038565b91508190509291505056fea2646970667358221220cd452e3e465719ec8fac7442c32b305abe534ee3da143b4ee8a1163d44ec7df464736f6c63430008140033",
}

// VaultABI is the input ABI used to generate the binding from.
// Deprecated: Use VaultMetaData.ABI instead.
var VaultABI = VaultMetaData.ABI

// VaultBin is the compiled bytecode used for deploying new contracts.
// Deprecated: Use VaultMetaData.Bin instead.
var VaultBin = VaultMetaData.Bin

// DeployVault deploys a new Ethereum contract, binding an instance of Vault to it.
func DeployVault(auth *bind.TransactOpts, backend bind.ContractBackend, owner_ common.Address) (common.Address, *types.Transaction, *Vault, error) {
	parsed, err := VaultMetaData.GetAbi()
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	if parsed == nil {
		return common.Address{}, nil, nil, errors.New("GetABI returned nil")
	}

	address, tx, contract, err := bind.DeployContract(auth, *parsed, common.FromHex(VaultBin), backend, owner_)
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
// Solidity: function setAuthorizer(address newAuthorizer) returns()
func (_Vault *VaultTransactor) SetAuthorizer(opts *bind.TransactOpts, newAuthorizer common.Address) (*types.Transaction, error) {
	return _Vault.contract.Transact(opts, "setAuthorizer", newAuthorizer)
}

// SetAuthorizer is a paid mutator transaction binding the contract method 0x058a628f.
//
// Solidity: function setAuthorizer(address newAuthorizer) returns()
func (_Vault *VaultSession) SetAuthorizer(newAuthorizer common.Address) (*types.Transaction, error) {
	return _Vault.Contract.SetAuthorizer(&_Vault.TransactOpts, newAuthorizer)
}

// SetAuthorizer is a paid mutator transaction binding the contract method 0x058a628f.
//
// Solidity: function setAuthorizer(address newAuthorizer) returns()
func (_Vault *VaultTransactorSession) SetAuthorizer(newAuthorizer common.Address) (*types.Transaction, error) {
	return _Vault.Contract.SetAuthorizer(&_Vault.TransactOpts, newAuthorizer)
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

// VaultDepositedIterator is returned from FilterDeposited and is used to iterate over the raw logs and unpacked data for Deposited events raised by the Vault contract.
type VaultDepositedIterator struct {
	Event *VaultDeposited // Event containing the contract specifics and raw log

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
func (it *VaultDepositedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(VaultDeposited)
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
		it.Event = new(VaultDeposited)
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
func (it *VaultDepositedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *VaultDepositedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// VaultDeposited represents a Deposited event raised by the Vault contract.
type VaultDeposited struct {
	User   common.Address
	Token  common.Address
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterDeposited is a free log retrieval operation binding the contract event 0x8752a472e571a816aea92eec8dae9baf628e840f4929fbcc2d155e6233ff68a7.
//
// Solidity: event Deposited(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) FilterDeposited(opts *bind.FilterOpts, user []common.Address, token []common.Address) (*VaultDepositedIterator, error) {

	var userRule []interface{}
	for _, userItem := range user {
		userRule = append(userRule, userItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _Vault.contract.FilterLogs(opts, "Deposited", userRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return &VaultDepositedIterator{contract: _Vault.contract, event: "Deposited", logs: logs, sub: sub}, nil
}

// WatchDeposited is a free log subscription operation binding the contract event 0x8752a472e571a816aea92eec8dae9baf628e840f4929fbcc2d155e6233ff68a7.
//
// Solidity: event Deposited(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) WatchDeposited(opts *bind.WatchOpts, sink chan<- *VaultDeposited, user []common.Address, token []common.Address) (event.Subscription, error) {

	var userRule []interface{}
	for _, userItem := range user {
		userRule = append(userRule, userItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _Vault.contract.WatchLogs(opts, "Deposited", userRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(VaultDeposited)
				if err := _Vault.contract.UnpackLog(event, "Deposited", log); err != nil {
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

// ParseDeposited is a log parse operation binding the contract event 0x8752a472e571a816aea92eec8dae9baf628e840f4929fbcc2d155e6233ff68a7.
//
// Solidity: event Deposited(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) ParseDeposited(log types.Log) (*VaultDeposited, error) {
	event := new(VaultDeposited)
	if err := _Vault.contract.UnpackLog(event, "Deposited", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// VaultWithdrawnIterator is returned from FilterWithdrawn and is used to iterate over the raw logs and unpacked data for Withdrawn events raised by the Vault contract.
type VaultWithdrawnIterator struct {
	Event *VaultWithdrawn // Event containing the contract specifics and raw log

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
func (it *VaultWithdrawnIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(VaultWithdrawn)
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
		it.Event = new(VaultWithdrawn)
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
func (it *VaultWithdrawnIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *VaultWithdrawnIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// VaultWithdrawn represents a Withdrawn event raised by the Vault contract.
type VaultWithdrawn struct {
	User   common.Address
	Token  common.Address
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterWithdrawn is a free log retrieval operation binding the contract event 0xd1c19fbcd4551a5edfb66d43d2e337c04837afda3482b42bdf569a8fccdae5fb.
//
// Solidity: event Withdrawn(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) FilterWithdrawn(opts *bind.FilterOpts, user []common.Address, token []common.Address) (*VaultWithdrawnIterator, error) {

	var userRule []interface{}
	for _, userItem := range user {
		userRule = append(userRule, userItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _Vault.contract.FilterLogs(opts, "Withdrawn", userRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return &VaultWithdrawnIterator{contract: _Vault.contract, event: "Withdrawn", logs: logs, sub: sub}, nil
}

// WatchWithdrawn is a free log subscription operation binding the contract event 0xd1c19fbcd4551a5edfb66d43d2e337c04837afda3482b42bdf569a8fccdae5fb.
//
// Solidity: event Withdrawn(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) WatchWithdrawn(opts *bind.WatchOpts, sink chan<- *VaultWithdrawn, user []common.Address, token []common.Address) (event.Subscription, error) {

	var userRule []interface{}
	for _, userItem := range user {
		userRule = append(userRule, userItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _Vault.contract.WatchLogs(opts, "Withdrawn", userRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(VaultWithdrawn)
				if err := _Vault.contract.UnpackLog(event, "Withdrawn", log); err != nil {
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

// ParseWithdrawn is a log parse operation binding the contract event 0xd1c19fbcd4551a5edfb66d43d2e337c04837afda3482b42bdf569a8fccdae5fb.
//
// Solidity: event Withdrawn(address indexed user, address indexed token, uint256 amount)
func (_Vault *VaultFilterer) ParseWithdrawn(log types.Log) (*VaultWithdrawn, error) {
	event := new(VaultWithdrawn)
	if err := _Vault.contract.UnpackLog(event, "Withdrawn", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
