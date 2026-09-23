// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DeploymentInfo {
    uint256 public constant BSC_CHAIN_ID = 56;

    // Binance Oracle BNB Chain Feed Registry.
    address public constant BINANCE_ORACLE_REGISTRY =
        0x55328A2dF78C5E379a3FeE693F47E6d4279C2193;

    // BNB Smart Chain USDT contract used as collateral/reference token.
    address public constant BSC_USDT =
        0x55d398326f99059fF775485246999027B3197955;

    string public constant ORACLE_BASE = "USDT";
    string public constant ORACLE_QUOTE = "USD";
}
