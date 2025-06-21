# Auction: Smart Contract

This smart contract implements an on-chain auction system and is designed to be deployed from your own address.

## Features

### Place Bid Function

Allows participants to place bids on the item.

A bid is valid if:

- It is at least **5% higher** than the current highest bid.  
- It is placed while the auction is **active**.

### Show Winner

- Returns the address of the **winning bidder** and the amount of the winning bid.

### Show Bids

- Returns a list of **bidders** and their respective **bid amounts**.

### Refund Funds

- Refund deposits to **non-winning bidders**.  
- Deduct a **2% fee**.

### Deposit Management

- Bids must be **deposited into the contract**.  
- Bids must be linked to the **bidder’s address**.

### Events

- `PlaceNewBidEvent`: Emitted when a new bid is placed.  
- `FinalizeAuction`: Emitted when the auction ends.


## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

All tests passes and we have a 94% of code coverage in the `src/AuctionWhatever.sol` file.

### Format

```shell
$ forge fmt
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

Some examples of how to test the contract:

```shell
$ cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "createArticle(string,string,uint256,uint16)" "Pencil" "This is an special pencil." 10000000000000000 7 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
$ cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "createArticle(string,string,uint256,uint16)" "Special Book" "This is an special book." 20000000000000000 7 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
$ cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "createArticle(string,string,uint256,uint16)" "Computer" "This is an special computer." 10000000000000000 7 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

$ cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "articles(uint256)(string,string,uint256,uint256,uint256)" 0 \
  --rpc-url $RPC_URL

$ cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "placeBid(uint256)" 0 \
  --rpc-url $RPC_URL --value 7ether --private-key $PRIVATE_KEY_USER_1

$ cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "showBids(uint256,address)(uint256)" 0 $ADDRESS_USER_1 \
--rpc-url $RPC_URL

$ cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "showWinner(uint256)(address, uint256)" 0 \
--rpc-url $RPC_URL
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
