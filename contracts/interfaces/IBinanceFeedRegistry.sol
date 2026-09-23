// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IBinanceFeedRegistry {
    function latestRoundDataByName(string calldata base, string calldata quote)
        external view returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function decimalsByName(string calldata base, string calldata quote)
        external view returns (uint8);
}
