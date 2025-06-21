// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {AuctionWhatever} from "../src/AuctionWhatever.sol";
import {Constants} from "../src/Constants.sol";

contract AuctionWhateverTest is Test {
    AuctionWhatever auctionWhatever;
    address articleOwner = address(1320);

    function setUp() external {
        auctionWhatever = new AuctionWhatever();
        vm.warp(1641070800);
        vm.prank(articleOwner);
        auctionWhatever.createArticle("Pencil", "An incredible pencil", 1 ether, 7);
    }

    function testCreateArticleShouldAddAnItemToArticles() public {
        address articleOwner2 = address(1321);
        vm.prank(articleOwner2);
        auctionWhatever.createArticle("Other Pencil", "An incredible pencil", 10 ether, 7);
        (,, uint256 initialPrice,,,,, address originalOwner, bool finalized) = auctionWhatever.articles(1);

        assertEq(initialPrice, 10 ether);
        assertEq(originalOwner, articleOwner2);
        assertEq(finalized, false);
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

    function testCreateArticleShouldHaveValidDurationDaysNoLongerThanAMonth() public {
        vm.expectRevert();
        auctionWhatever.createArticle("Pencil", "An incredible pencil", 0, 31);
    }

    function testPlaceBid() public {
        uint256 bidAmount = 5 ether;
        address fake_user = address(1337);

        vm.warp(1641070800);
        vm.prank(fake_user);
        vm.deal(fake_user, 10 ether);

        auctionWhatever.placeBid{value: bidAmount}(0);

        (,,,,, uint256 highestBid, address winner,,) = auctionWhatever.articles(0);

        assertEq(highestBid, bidAmount);
        assertEq(winner, fake_user);
        // assertEq(auctionWhatever.bidders(0, fake_user), bidAmount);
        assertEq(auctionWhatever.showBids(0, fake_user), bidAmount);
    }

    function testPlaceBidRaise() public {
        uint256 initialBidAmount = 5 ether;
        uint256 bidAmountToAdd = 1 ether;
        uint256 expectedBidAmount = 6 ether;
        address fake_user = address(1337);

        vm.warp(1641070800);
        vm.prank(fake_user);
        vm.deal(fake_user, 10 ether);

        auctionWhatever.placeBid{value: initialBidAmount}(0);

        vm.prank(fake_user);
        vm.deal(fake_user, 10 ether);

        auctionWhatever.placeBid{value: bidAmountToAdd}(0);

        (,,,,, uint256 highestBid, address winner,,) = auctionWhatever.articles(0);

        assertEq(highestBid, expectedBidAmount);
        assertEq(winner, fake_user);
    }

    function testPlaceBidReplaceWinner() public {
        uint256 initialBidAmount = 5 ether;
        uint256 otherBidAmount = 10 ether;

        address fake_user = address(1337);
        address fake_user_2 = address(1338);

        vm.warp(1641070800);
        vm.prank(fake_user);
        vm.deal(fake_user, 10 ether);
        auctionWhatever.placeBid{value: initialBidAmount}(0);

        vm.prank(fake_user_2);
        vm.deal(fake_user_2, 20 ether);

        auctionWhatever.placeBid{value: otherBidAmount}(0);

        (,,,,, uint256 highestBid, address winner,,) = auctionWhatever.articles(0);

        assertEq(highestBid, otherBidAmount);
        assertEq(winner, fake_user_2);
    }

    function testPlaceBidInvalidAmountPercentage() public {
        uint256 initialBidAmount = 100 ether;
        uint256 secondBidAmount = 104 ether; // initialBidAmount + initialBidAmount*0.05 - 1

        address fake_user = address(1337);
        address fake_user_2 = address(1338);

        vm.warp(1641070800);
        vm.prank(fake_user);
        vm.deal(fake_user, 150 ether);

        auctionWhatever.placeBid{value: initialBidAmount}(0);

        vm.prank(fake_user_2);
        vm.deal(fake_user_2, 150 ether);

        vm.expectRevert(bytes(Constants.INVALID_PRICE_PERCENTAGE_MSG));
        auctionWhatever.placeBid{value: secondBidAmount}(0);
    }

    function testPlaceBidArticleNoLongerAvailable() public {
        uint256 initialBidAmount = 100 ether;
        vm.warp(1641070800);
        auctionWhatever.createArticle("No Longer Available Article", "An incredible pencil", 1 ether, 7);

        vm.warp(9641070800); //long time in the future
        address fake_user = address(1337);

        vm.prank(fake_user);
        vm.deal(fake_user, 150 ether);

        vm.expectRevert(bytes(Constants.ARTICLE_NO_LONGER_AVAILABLE_MSG));
        auctionWhatever.placeBid{value: initialBidAmount}(0);
    }

    function testPlaceBidArticleDoesNotExist() public {
        uint256 initialBidAmount = 100 ether;
        address fake_user = address(1337);

        vm.prank(fake_user);
        vm.deal(fake_user, 150 ether);

        vm.expectRevert(bytes(Constants.ARTICLE_DOES_NOT_EXISTS));
        auctionWhatever.placeBid{value: initialBidAmount}(10);
    }

    function testShowBids() public {
        uint256 initialBidAmount = 100 ether;
        address fake_user = address(1337);

        vm.prank(fake_user);
        vm.deal(fake_user, 150 ether);
        auctionWhatever.placeBid{value: initialBidAmount}(0);

        assertEq(auctionWhatever.showBids(0, fake_user), initialBidAmount);
    }

    function testShowWinner() public {
        uint256 initialBidAmount = 100 ether;
        address fake_user = address(1337);

        vm.prank(fake_user);
        vm.deal(fake_user, 150 ether);
        auctionWhatever.placeBid{value: initialBidAmount}(0);
        (address winner, uint256 highestBid) = auctionWhatever.showWinner(0);

        assertEq(winner, fake_user);
        assertEq(highestBid, initialBidAmount);
    }

    function testGetRefundAsWinner() public {
        address fake_user = address(1337);
        address fake_user2 = address(1338);
        address fake_user3 = address(1339);

        // first bid
        vm.prank(fake_user);
        vm.deal(fake_user, 150 ether);
        auctionWhatever.placeBid{value: 50}(0);

        // second bid
        vm.prank(fake_user2);
        vm.deal(fake_user2, 150 ether);
        auctionWhatever.placeBid{value: 70}(0);

        // third bid
        vm.prank(fake_user3);
        vm.deal(fake_user3, 150 ether);
        auctionWhatever.placeBid{value: 100}(0);

        // try to get refund as winner
        vm.warp(941070800);
        vm.prank(fake_user3);
        vm.expectRevert(bytes(Constants.INVALID_WINNER_REFUND_MSG));
        auctionWhatever.returnFunds(0);
    }

    function testGetRefundAsParticipant() public {
        address fake_user = address(1337);
        address fake_user2 = address(1338);
        address fake_user3 = address(1339);

        // first bid
        vm.prank(fake_user);
        vm.deal(fake_user, 150 ether);
        auctionWhatever.placeBid{value: 50 ether}(0);

        // second bid
        vm.prank(fake_user2);
        vm.deal(fake_user2, 150 ether);
        auctionWhatever.placeBid{value: 100 ether}(0);
        assertEq(fake_user2.balance, 50 ether);

        // third bid
        vm.prank(fake_user3);
        vm.deal(fake_user3, 150 ether);
        auctionWhatever.placeBid{value: 150 ether}(0);

        // try to get refund as participant
        vm.prank(fake_user2);
        auctionWhatever.returnFunds(0);
        assertEq(fake_user2.balance, 148 ether);
    }

    function testFinalizeAuctionEarly() public {
        address fake_user = address(1337);

        // first bid
        vm.prank(fake_user);
        vm.deal(fake_user, 150 ether);
        auctionWhatever.placeBid{value: 50 ether}(0);

        vm.warp(1641070801);
        vm.expectRevert();
        vm.prank(articleOwner);
        auctionWhatever.finalizeAuction(0);
    }

    function testFinalizeAuctionNotOwner() public {
        address fake_user = address(1337);

        // first bid
        vm.prank(fake_user);
        vm.deal(fake_user, 150 ether);
        auctionWhatever.placeBid{value: 50 ether}(0);

        vm.warp(9641070800);
        vm.expectRevert();
        vm.prank(fake_user);
        auctionWhatever.finalizeAuction(0);
    }

    function testFinalizeAuctionSuccess() public {
        address fake_user = address(1337);

        // first bid
        vm.prank(fake_user);
        vm.deal(fake_user, 150 ether);
        auctionWhatever.placeBid{value: 50 ether}(0);

        vm.warp(9641070800);
        vm.prank(articleOwner);
        auctionWhatever.finalizeAuction(0);

        (,,,,,,,, bool finalized) = auctionWhatever.articles(0);
        assertEq(finalized, true);
    }
}
