## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

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
$ forge script script/DeployAuctionWhatever.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### Cast

```shell
$ cast send 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 "create(string,string,uint256,uint16)" "Pencil" "This is an special pencil." 10000000000000000 7 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
$ cast send 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 "create(string,string,uint256,uint16)" "Special Book" "This is an special book." 20000000000000000 7 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
$ cast send 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 "create(string,string,uint256,uint16)" "Computer" "This is an special computer." 10000000000000000 7 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

$ cast call 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 "articles(uint256)(string,string,uint256,uint256,uint256)" 1 \
  --rpc-url $RPC_URL
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
