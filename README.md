# USDT Price Tracker — BNB Smart Chain

This repository contains a clearly distinct ERC-20/BEP-20 token architecture that tracks the USD value of USDT on BNB Smart Chain.

**This project is not Tether and must not be presented as genuine Tether USD₮.**

## Network

- BNB Smart Chain mainnet
- Chain ID: 56
- Native gas token: BNB

## Verified integration constants

### Binance Oracle

The project uses Binance Oracle's BNB Chain Feed Registry:

`0x55328A2dF78C5E379a3FeE693F47E6d4279C2193`

The registry supports:

`latestRoundDataByName("USDT", "USD")`

### Reference collateral

BNB Smart Chain USDT:

`0x55d398326f99059fF775485246999027B3197955`

The referenced BNB Chain token uses 18 decimals.

## Token model

- Tracker token: `USDT Price Tracker`
- Symbol: `tUSDT`
- Decimals: 18
- Initial supply: 0
- 1 USDT deposited → 1 tUSDT minted
- 1 tUSDT redeemed → 1 USDT returned
- The vault maintains 100% USDT collateralization.
- The oracle supplies the external USDT/USD reference price and acts as a safety/health check.
- A DEX price can still move temporarily; redemption and arbitrage provide the economic anchor.

## Oracle safety

The adapter checks:

- positive answer
- non-zero update timestamp
- no future timestamp
- maximum oracle age
- completed round
- configurable deviation from $1

Default health window:

- maximum age: 1 hour
- maximum deviation: 1%

## Deployment in Remix

1. Open the GitHub repository in Remix.
2. Compile with Solidity `0.8.24`.
3. Connect MetaMask to **BNB Smart Chain mainnet (chain ID 56)**.
4. Deploy `USDTOracleAdapter`:
   - `registryAddress` = `0x55328A2dF78C5E379a3FeE693F47E6d4279C2193`
   - `initialOwner` = your wallet
5. Deploy `TrackedToken`:
   - `initialOwner` = your wallet
6. Deploy `USDTTrackerVault`:
   - `token` = deployed `TrackedToken`
   - `usdt` = `0x55d398326f99059fF775485246999027B3197955`
   - `oracleAdapter` = deployed `USDTOracleAdapter`
   - `initialOwner` = your wallet
7. On `TrackedToken`, call `setVault(vaultAddress)`.
8. On the real BNB-chain USDT contract, approve the vault to spend the amount you want to deposit.
9. Call `USDTTrackerVault.deposit(amount)`.
10. The vault mints the same amount of `tUSDT`.
11. Call `redeem(amount)` to burn `tUSDT` and return the collateral USDT.

### Amount format

The BNB-chain USDT reference uses 18 decimals. Therefore:

- 1 USDT = `1000000000000000000`
- 10 USDT = `10000000000000000000`

## Important

Do not use the genuine Tether name/symbol/logo in a way that implies the tracker is issued by Tether.

Always identify the exact deployed contract address.

## Repository layout

```text
contracts/
├── TrackedToken.sol
├── USDTOracleAdapter.sol
├── USDTTrackerVault.sol
├── DeploymentInfo.sol
└── interfaces/
    ├── IBinanceFeedRegistry.sol
    └── IERC20.sol

scripts/
tests/
deployments/
docs/
```
