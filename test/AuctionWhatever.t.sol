// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {AuctionWhatever} from "../src/AuctionWhatever.sol";

contract AuctionWhateverTest is Test {
    AuctionWhatever auctionWhatever;

    function setUp() external {
        auctionWhatever = new AuctionWhatever();
    }

    function testCreateArticleShouldAddAnItemToArticles() public {
        auctionWhatever.createArticle(
            "Pencil",
            "An incredible pencil",
            10e18,
            7
        );
        (, , uint256 initialPrice, , , , ) = auctionWhatever.articles(0);

        assertEq(initialPrice, 10e18);
    }

    function testCreateArticleShouldRevertWhenPriceIsZero() public {
        vm.expectRevert();
        auctionWhatever.createArticle("Pencil", "An incredible pencil", 0, 7);
    }

    function testCreateArticleShouldRevertWhenDescriptionIsShort() public {
        vm.expectRevert();
        auctionWhatever.createArticle("Pencil", "Short", 0, 7);
    }

    function testCreateArticleShouldRevertWhenNameIsShort() public {
        vm.expectRevert();
        auctionWhatever.createArticle("St", "An incredible pencil", 0, 7);
    }

    function testCreateArticleShouldHaveValidDurationDays() public {
        vm.expectRevert();
        auctionWhatever.createArticle("Pencil", "An incredible pencil", 0, 0);
    }

    function testCreateArticleShouldHaveValidDurationDaysNoLongerThanAMonth()
        public
    {
        vm.expectRevert();
        auctionWhatever.createArticle("Pencil", "An incredible pencil", 0, 31);
    }

    function testPlaceBid() public {
        uint256 bidAmount = 5 ether;
        address fake_user = address(1337);

        vm.warp(1641070800);
        auctionWhatever.createArticle(
            "Pencil",
            "An incredible pencil",
            1 ether,
            7
        );

        vm.prank(fake_user);
        vm.deal(fake_user, 10 ether);

        auctionWhatever.placeBid{value: bidAmount}(0);

        (, , , , , uint256 highestBid, address winner) = auctionWhatever
            .articles(0);

        assertEq(highestBid, bidAmount);
        assertEq(winner, fake_user);
    }

    function testPlaceBidRaise() public {
        uint256 initialBidAmount = 5 ether;
        uint256 bidAmountToAdd = 1 ether;
        uint256 expectedBidAmount = 6 ether;
        address fake_user = address(1337);

        vm.warp(1641070800);
        auctionWhatever.createArticle(
            "Pencil",
            "An incredible pencil",
            1 ether,
            7
        );

        vm.prank(fake_user);
        vm.deal(fake_user, 10 ether);

        auctionWhatever.placeBid{value: initialBidAmount}(0);

        vm.prank(fake_user);
        vm.deal(fake_user, 10 ether);

        auctionWhatever.placeBid{value: bidAmountToAdd}(0);

        (, , , , , uint256 highestBid, address winner) = auctionWhatever
            .articles(0);

        assertEq(highestBid, expectedBidAmount);
        assertEq(winner, fake_user);
    }
}
