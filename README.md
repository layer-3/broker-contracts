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

## Development Setup

### Code Formatting

This project uses `forge fmt` for consistent Solidity code formatting. We follow an editor-agnostic approach with additional convenience settings for VS Code users.

#### Editor-Agnostic Formatting

1. **Git Hooks**: The project includes pre-commit hooks that automatically format Solidity files using `forge fmt` before each commit.

   To set up the pre-commit hook:

   ```bash
   # Configure git to use the hooks in the .githooks directory
   git config core.hooksPath .githooks
   ```

2. **EditorConfig**: The project includes an `.editorconfig` file with basic formatting rules that many editors support.

   To use these settings:

   - Install an EditorConfig plugin for your editor if it doesn't have built-in support
   - The plugin will automatically apply basic formatting rules (indentation, line endings, etc.)

   More information about EditorConfig can be found at [https://editorconfig.org/](https://editorconfig.org/)

#### VS Code-Specific Settings

For VS Code users, additional settings are provided in `.vscode/settings.json` that:

- Configure VS Code to use `forge fmt` automatically when saving Solidity files
- Ensure consistent formatting directly in the editor

These settings are optional and only apply to VS Code users. Other editors may need their own configuration to exactly match `forge fmt` behavior.

#### Recommended Workflow

The recommended workflow for all developers, regardless of editor:

1. Use the pre-commit hooks to ensure consistent formatting in the repository
2. If needed, run `forge fmt` manually before committing to see changes

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
