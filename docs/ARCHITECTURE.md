# Architecture

External USDT/USD market data
        |
        v
Binance Oracle BNB Feed Registry
        |
        v
USDTOracleAdapter
        |
        +---- price18()
        +---- isHealthy()
        |
        v
USDTTrackerVault <---- BNB-chain USDT collateral
        |
        v
TrackedToken (tUSDT)

The oracle provides the reference price. The 1:1 USDT reserve and redemption mechanism provide the economic anchor.

The oracle alone does not force a DEX market price.
