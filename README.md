# Broker Contracts

This repository contains smart contracts for the Broker entity in the Yellow Network.

## Contracts

### BrokerToken

Broker and Canary utility token is a simple ERC20 token with permit functionality. All the supply is minted to the deployer.

### LiteVault

A simple vault that allows users to deposit and withdraw tokens. Deposit is allowed regardless of the time, whereas withdrawal is allowed only when authorized by the Authorizer contract.
LiteVault Owner can change the Authorizer contract, which will enable a grace withdrawal period for 3 days, during which users will be able to withdraw their funds.

### TimeRangeAuthorizer

Authorizer contract that authorize withdrawal regardless of token and amount, but only outside of the time range specified on deployment.

## Deployment and interaction

This repository uses Foundry toolchain for development, testing and deployment.

### Documentation

https://book.getfoundry.sh/

### Compile and generate artifacts

```shell
$ forge build [contract]
```

### Generate LiteVault interface

```shell
$ make all
```

### Test

```shell
$ forge test []
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Deploy

```shell
$ forge create <contract> --constructor-args [C_ARGS] -r $RPC_URL --private-key $PRIV_KEY [--optimizer-runs <runs> --via-ir]
```

### Interact

To interact with smart contracts, use `cast` command with either `call` or `send` subcommand to read or write data respectively.

```shell
$ cast call <contract_address> "<method_signature>" [params] -r $RPC_URL
```

```shell
$ cast send <contract_address> "<method_signature>" [params] -r $RPC_URL --private-key $PRIV_KEY
```
