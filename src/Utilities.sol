// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Constants} from "./Constants.sol";

library Utilities {
    function getPercentage(uint8 percentage, uint256 value) internal pure returns (uint256) {
        uint256 convertedPercentage = (percentage * 10 ** Constants.DECIMALS) / 10 ** 2; // 5%

        return (value * convertedPercentage) / 10 ** Constants.DECIMALS;
    }
}
