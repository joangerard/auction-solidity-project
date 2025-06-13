// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {AuctionWhatever} from "../src/AuctionWhatever.sol";

contract DeployAuctionWhatever is Script {
    function run() public returns (AuctionWhatever) {
        vm.startBroadcast();
        AuctionWhatever auctionWhatever = new AuctionWhatever();
        vm.stopBroadcast();

        return auctionWhatever;
    }
}
