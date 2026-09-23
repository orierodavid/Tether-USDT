# Tests

Recommended tests:

1. Oracle returns a positive, fresh USDT/USD price.
2. Deposit mints exactly the deposited USDT amount.
3. Redeem burns exactly the redeemed tracker amount.
4. Vault collateral equals tracker total supply after normal operation.
5. Deposit/redeem stops when the oracle is stale or outside the configured deviation.
6. Non-vault addresses cannot mint or burn.
