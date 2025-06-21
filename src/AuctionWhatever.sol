// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Constants} from "./Constants.sol";
import {Utilities} from "./Utilities.sol";
import {IterableMapping} from "./IterableMapping.sol";

error Auction__NotOwner();

contract AuctionWhatever {
    using IterableMapping for IterableMapping.Map;
    uint256 private lastId = 0;
    address public immutable i_owner;
    mapping(uint256 id => Article) public articles;
    mapping(uint256 articleId => IterableMapping.Map map) private bidders;
    struct Article {
        string name;
        string description;
        uint256 initialPrice;
        uint256 startDate;
        uint256 endDate;
        uint256 highestBid;
        address winner;
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner);
        if (msg.sender != i_owner) revert Auction__NotOwner();
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }

    function createArticle(
        string memory name,
        string memory description,
        uint256 initialPrice,
        uint16 durationDays
    ) external {
        require(initialPrice > 0, "Price must be greater than 0.");
        require(
            bytes(description).length > Constants.MIN_NAME_LENGTH,
            "Description must contain more than 10 characters."
        );
        require(
            bytes(name).length > Constants.MIN_NAME_LENGTH,
            "Name must contain more than 4 characters."
        );
        require(
            durationDays > 0 && durationDays < 31,
            "Duration must be between 1 and 30 calendar days."
        );

        Article storage article = articles[lastId];
        article.name = name;
        article.description = description;
        article.initialPrice = initialPrice;
        article.startDate = block.timestamp;
        article.endDate = block.timestamp + (durationDays * 1 days);
        lastId++;
    }

    function placeBid(uint256 articleId) external payable {
        uint256 amountToAdd = msg.value;
        require(articleId < lastId, Constants.ARTICLE_DOES_NOT_EXISTS);

        Article storage article = articles[articleId];
        require(
            block.timestamp < article.endDate,
            Constants.ARTICLE_NO_LONGER_AVAILABLE_MSG
        );

        // get last bid price for that address and add to what it is on place
        uint256 totalAmount = bidders[articleId].get(msg.sender) + amountToAdd;

        uint256 offerPercentage = Utilities.getPercentage(
            Constants.FIXED_PERCENTAGE,
            article.highestBid
        );
        require(
            totalAmount > article.highestBid + offerPercentage,
            Constants.INVALID_PRICE_PERCENTAGE_MSG
        );

        // update new winner so far
        article.highestBid = totalAmount;
        article.winner = msg.sender;

        // keep track of sent amounts per article per address
        bidders[articleId].set(msg.sender, totalAmount);
    }

    function showBids(
        uint256 articleId,
        address bidder
    ) external view returns (uint256) {
        return bidders[articleId].get(bidder);
    }

    function returnFunds(uint256 articleId) external {
        Article storage article = articles[articleId];
        uint256 bidAmount = bidders[articleId].get(msg.sender);

        // verify auction amount was not already refund
        require(
            msg.sender != article.winner,
            Constants.INVALID_WINNER_REFUND_MSG
        );
        require(bidAmount > 0, "You're amount is 0");

        uint256 commission = Utilities.getPercentage(
            Constants.FIXED_PERCENTAGE_REFUND,
            bidAmount
        );

        uint256 refundAmount = bidAmount - commission;

        bidders[articleId].set(msg.sender, 0);

        (bool success, ) = msg.sender.call{value: refundAmount}("");

        if (!success) {
            revert(
                "Something happened during the transaction. Please, try again."
            );
        }

        // only owner can execute this method
        // iterate through binders and return money to each of them less the percentage fee (2%)
    }

    function showWinner(
        uint256 articleId
    ) external view returns (address, uint256) {
        return (articles[articleId].winner, articles[articleId].highestBid);
    }
}
