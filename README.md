# Broker contracts

This repository contains the smart contracts for the Yellow Network Brokerages as well as for other Yellow Network services.

## Commands

### Compile contracts

```shell
forge build
```

### Generate interfaces

```shell
  make all
```

## Deployed contracts

### Mainnet

#### Ethereum

Chain id: `1`.

Last updated: September 6, 2024.

| Description           | Contract Name       | Transaction Hash                                                                                            | Address                                                                                                                  | Git SHA                                  | Notes                                                     |
| --------------------- | ------------------- | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------- | --------------------------------------------------------- |
| Time range authorizer | TimeRangeAuthorizer | [0xd512...23e2](https://etherscan.io/tx/0xd512b239694e4ddb8255cbc0fac47eb4733dcbeaf270d9d63b788b6850f823e2) | `0x547d613C2f613c9bC78d49051093F092924aaD1c`[↗](https://etherscan.io/address/0x547d613C2f613c9bC78d49051093F092924aaD1c) | fff15f51b0e6c3963aeeb01b0f3ce661721c8c9b | Time range is set to Sep 6th - November 10th 23:59:59 UTC |

#### Polygon

Chain id: `137`.

Last updated: September 6, 2024.

| Description           | Contract Name       | Transaction Hash                                                                                               | Address                                                                                                                     | Git SHA                                  | Notes                                                     |
| --------------------- | ------------------- | -------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- | --------------------------------------------------------- |
| Time range authorizer | TimeRangeAuthorizer | [0xf05c...d6b6](https://polygonscan.com/tx/0xf05c56617b939c8876d01619947136921d8793595d41c26bf52fb0b21d1cd6b6) | `0x547d613C2f613c9bC78d49051093F092924aaD1c`[↗](https://polygonscan.com/address/0x547d613C2f613c9bC78d49051093F092924aaD1c) | fff15f51b0e6c3963aeeb01b0f3ce661721c8c9b | Time range is set to Sep 6th - November 10th 23:59:59 UTC |

#### Linea

Chain id: `59144`.

Last updated: September 6, 2024.

| Description           | Contract Name       | Transaction Hash                                                                                               | Address                                                                                                                     | Git SHA                                  | Notes                                                     |
| --------------------- | ------------------- | -------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- | --------------------------------------------------------- |
| Time range authorizer | TimeRangeAuthorizer | [0x57d0...90d9](https://lineascan.build/tx/0x57d0f6faf6c97b33b5095f1d83a9f051484c15a42ea5567398593461872890d9) | `0x547d613C2f613c9bC78d49051093F092924aaD1c`[↗](https://lineascan.build/address/0x547d613C2f613c9bC78d49051093F092924aaD1c) | fff15f51b0e6c3963aeeb01b0f3ce661721c8c9b | Time range is set to Sep 6th - November 10th 23:59:59 UTC |

### Testnet

#### Sepolia

Chain id: `11155111`.

Last updated: August 22, 2024.

| Description           | Contract Name       | Transaction Hash                                                                                                    | Address                                                                                                                          | Git SHA                                  | Notes                                                |
| --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- | ---------------------------------------------------- |
| Time range authorizer | TimeRangeAuthorizer | [0x6b07...a0b1](https://sepolia.etherscan.io/tx/0x6b07207c07e1cb5d630f8673136a997c05e5aab85c765097a887624db836a0b1) | `0xc1544839D4a7De5a9b88c9DEc2Bb824C2f998084`[↗](https://sepolia.etherscan.io/address/0xc1544839D4a7De5a9b88c9DEc2Bb824C2f998084) | cc273464bd6ea6c4d45cdad33c325ed5684b0a01 | Time range is set to Aug 1st - Aug 31st 23:59:59 UTC |
| Time range authorizer | TimeRangeAuthorizer | [0x5d7e...acd9](https://sepolia.etherscan.io/tx/0x5d7e53bf0a4009d49c88af4d9f213282e11759d9a5e336827506a5d3d97eacd9) | `0x68bEcD75b098F602eb92A110934ce0f675D7e305`[↗](https://sepolia.etherscan.io/address/0x68bEcD75b098F602eb92A110934ce0f675D7e305) | cc273464bd6ea6c4d45cdad33c325ed5684b0a01 | Time range is set to Aug 1st - Aug 15st 00:00:00 UTC |
| Yellow Vault          | LiteVault           | [0x4e3e...74f0](https:/sepolia./etherscan.io/tx/0x4e3e891dae649b8105802e6c92dfcd3b2a316b33484aed58c6072e8abb8f74f0) | `0xdAD067C90af43948f2A389DFC93d94481A72705c`[↗](https://sepolia.etherscan.io/address/0xdAD067C90af43948f2A389DFC93d94481A72705c) | 7377e0ee10a567725e84bb47d4fddbc02e305749 |                                                      |

#### Linea Sepolia

Chain id: `59141`.

Last updated: August 22, 2024.

| Description           | Contract Name       | Transaction Hash                                                                                                       | Address                                                                                                                             | Git SHA                                  | Notes                                                |
| --------------------- | ------------------- | ---------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- | ---------------------------------------------------- |
| Time range authorizer | TimeRangeAuthorizer | [0x9d47...c39f](https://sepolia.lineascan.build/tx/0x9d475a064b09b9666a1927646a5f783843b9c1ff735b4e07ef51c80a7100c39f) | `0x0d26A24DaF55Bc2e435Ac798cD400edd8d6D8b33`[↗](https://sepolia.lineascan.build/address/0x0d26A24DaF55Bc2e435Ac798cD400edd8d6D8b33) | cc273464bd6ea6c4d45cdad33c325ed5684b0a01 | Time range is set to Aug 1st - Aug 31st 23:59:59 UTC |
| Time range authorizer | TimeRangeAuthorizer | [0xab5c...5bee](https://sepolia.lineascan.build/tx/0xab5c1dababbee69514c9afb3f256a07bfb8c8f03c91d5a25514cfbd7266d5bee) | `0xc1544839D4a7De5a9b88c9DEc2Bb824C2f998084`[↗](https://sepolia.lineascan.build/address/0xc1544839D4a7De5a9b88c9DEc2Bb824C2f998084) | cc273464bd6ea6c4d45cdad33c325ed5684b0a01 | Time range is set to Aug 1st - Aug 15st 00:00:00 UTC |
| Yellow Vault          | LiteVault           | [0xc72b...a10c](https://sepolia.lineascan.build/tx/0xc72b2b9c7ce76d6d28f7ec707c40836b9cf3732b329989eeb9a163e5841da10c) | `0x67c5751b62BaD721969bb996Ea0dbdF731267643`[↗](https://sepolia.lineascan.build/address/0x67c5751b62BaD721969bb996Ea0dbdF731267643) | 7377e0ee10a567725e84bb47d4fddbc02e305749 |                                                      |
