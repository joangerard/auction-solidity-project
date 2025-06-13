// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Constants} from "./Constants.sol";
import {Utilities} from "./Utilities.sol";

error Auction__NotOwner();

contract AuctionWhatever {
    uint256 private lastId = 0;
    address public immutable i_owner;
    mapping(uint256 id => Article) public articles;
    struct Article {
        string name;
        string description;
        uint256 initialPrice;
        uint256 startDate;
        uint256 endDate;
        uint256 highestBid;
        address winner;
        mapping(address => uint256 totalSpent) bidders;
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

        lastId++;
        Article storage article = articles[lastId];
        article.name = name;
        article.description = description;
        article.initialPrice = initialPrice;
        article.startDate = block.timestamp;
        article.endDate = block.timestamp + (durationDays * 1 days);
    }

    function placeBid(uint256 articleId) external payable {
        uint256 amountToAdd = msg.value;
        require(articleId <= lastId, "The article doesn't exists");

        Article storage article = articles[articleId];
        require(
            block.timestamp < article.endDate,
            "Article is no longer available."
        );
        require(
            block.timestamp > article.startDate,
            "Article is not available yet."
        );

        // get last bid price for that address and add to what it is on place
        uint256 totalAmount = article.bidders[msg.sender] + amountToAdd;

        uint256 offerPercentage = Utilities.getPercentage(
            Constants.FIXED_PERCENTAGE,
            article.highestBid
        );
        require(
            totalAmount > article.highestBid + offerPercentage,
            "Invalid price. Try a higher price!"
        );

        // update new winner so far
        article.highestBid = totalAmount;
        article.winner = msg.sender;

        // keep track of sent amounts per article per address
        article.bidders[msg.sender] = totalAmount;
    }

    function showBids(
        uint256 articleId,
        address bidder
    ) external view returns (uint256) {
        return articles[articleId].bidders[bidder];
    }

    function showWinner(
        uint256 articleId
    ) external view returns (address, uint256) {
        return (articles[articleId].winner, articles[articleId].highestBid);
    }
}
