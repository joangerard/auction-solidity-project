// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library Constants {
    uint8 constant MIN_NAME_LENGTH = 4;
    uint8 constant DECIMALS = 18;
    uint8 constant FIXED_PERCENTAGE = 5;
    uint8 constant FIXED_PERCENTAGE_REFUND = 2;
    string constant INVALID_PRICE_PERCENTAGE_MSG = "Invalid price. Try a higher price!";

    string constant ARTICLE_NO_LONGER_AVAILABLE_MSG = "Article is no longer available.";

    string constant ARTICLE_DOES_NOT_EXISTS = "The article doesn't exists";

    string constant INVALID_WINNER_REFUND_MSG = "You can't get refund because you're the winner";
}
