// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IBinanceFeedRegistry.sol";

/// @notice Reads Binance Oracle's BNB Chain USDT/USD feed.
contract USDTOracleAdapter {
    IBinanceFeedRegistry public immutable registry;
    string public constant BASE = "USDT";
    string public constant QUOTE = "USD";

    uint256 public maxStaleTime = 1 hours;
    uint256 public maxDeviationBps = 100; // 1%
    address public owner;

    event RiskParametersUpdated(uint256 maxStaleTime, uint256 maxDeviationBps);

    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }

    constructor(address registryAddress, address initialOwner) {
        require(registryAddress != address(0) && initialOwner != address(0), "zero address");
        registry = IBinanceFeedRegistry(registryAddress);
        owner = initialOwner;
    }

    function setRiskParameters(
        uint256 newMaxStaleTime,
        uint256 newMaxDeviationBps
    ) external onlyOwner {
        require(newMaxStaleTime > 0, "stale time");
        require(newMaxDeviationBps <= 10000, "bps");
        maxStaleTime = newMaxStaleTime;
        maxDeviationBps = newMaxDeviationBps;
        emit RiskParametersUpdated(newMaxStaleTime, newMaxDeviationBps);
    }

    function rawPrice()
        public
        view
        returns (
            int256 answer,
            uint8 feedDecimals,
            uint256 updatedAt,
            uint80 roundId,
            uint80 answeredInRound
        )
    {
        (
            roundId,
            answer,
            ,
            updatedAt,
            answeredInRound
        ) = registry.latestRoundDataByName(BASE, QUOTE);

        feedDecimals = registry.decimalsByName(BASE, QUOTE);
    }

    /// @notice USDT/USD normalized to 18 decimals.
    function price18() public view returns (uint256) {
        (
            int256 answer,
            uint8 feedDecimals,
            uint256 updatedAt,
            uint80 roundId,
            uint80 answeredInRound
        ) = rawPrice();

        require(answer > 0, "invalid oracle price");
        require(updatedAt != 0 && updatedAt <= block.timestamp, "invalid timestamp");
        require(block.timestamp - updatedAt <= maxStaleTime, "stale oracle");
        require(answeredInRound >= roundId, "incomplete round");

        uint256 p = uint256(answer);

        if (feedDecimals < 18) {
            p *= 10 ** (18 - feedDecimals);
        } else if (feedDecimals > 18) {
            p /= 10 ** (feedDecimals - 18);
        }

        return p;
    }

    function isHealthy() public view returns (bool) {
        uint256 p = price18();
        uint256 oneDollar = 1e18;
        uint256 deviation = p > oneDollar ? p - oneDollar : oneDollar - p;
        return deviation <= (oneDollar * maxDeviationBps) / 10000;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero owner");
        owner = newOwner;
    }
}
