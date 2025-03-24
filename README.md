# Vault

## Overview

Tokenized Vaults with API is a yield-bearing smart contract that automatically invests user deposits into DeFi protocols like Aave and Compound. The vault dynamically reallocates funds based on the best available yields to maximize returns. Users receive tokenized vault shares representing their deposits, ensuring transparency and efficiency.

## Goal

The goal is to create an automated and optimized yield aggregator that allows users to seamlessly deposit funds and earn interest without manually managing their allocations. This project enhances DeFi accessibility by reducing complexity for users while ensuring optimal yield generation.

### Features
- Supports dynamic rebalancing between protocols to handle changing interest rates.
- Ensures security & efficiency by implementing upgradeable smart contracts.
- Future enhancements may include multi-asset support and emergency withdrawal mechanisms for risk mitigation.
- Future enhancements may support drop in UI for interactions.

## Resources

https://book.getfoundry.sh


### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Contributors
This project is part of the [Advanced Solidity Bootcamp](https://www.encode.club/advanced-solidity-bootcamp) organized by the Encode club.

- [Riccardo](https://github.com/riccardo-ssvlabs)
- [Paul](https://github.com/paulneup97)
- [Peterson](https://github.com/svenski123)


## Acknowledgments
Special thanks to the [Advanced Solidity Bootcamp](https://www.encode.club/advanced-solidity-bootcamp) team for organizing this event and providing us with the opportunity to learn and contribute to the Defi space.