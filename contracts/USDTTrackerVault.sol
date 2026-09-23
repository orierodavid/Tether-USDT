// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TrackedToken.sol";
import "./USDTOracleAdapter.sol";
import "./interfaces/IERC20.sol";

/// @notice 1:1 USDT-collateralized tracker.
/// 1 BNB-chain USDT deposited = 1 tUSDT minted.
/// 1 tUSDT redeemed = 1 BNB-chain USDT returned.
contract USDTTrackerVault {
    TrackedToken public immutable trackerToken;
    IERC20 public immutable collateralUSDT;
    USDTOracleAdapter public immutable oracle;

    address public owner;
    bool public depositsEnabled = true;
    bool public redemptionsEnabled = true;

    event Deposited(address indexed user, uint256 usdtAmount, uint256 trackerAmount);
    event Redeemed(address indexed user, uint256 trackerAmount, uint256 usdtAmount);
    event ControlsUpdated(bool depositsEnabled, bool redemptionsEnabled);

    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }

    constructor(
        address token,
        address usdt,
        address oracleAdapter,
        address initialOwner
    ) {
        require(
            token != address(0) &&
            usdt != address(0) &&
            oracleAdapter != address(0) &&
            initialOwner != address(0),
            "zero address"
        );

        trackerToken = TrackedToken(token);
        collateralUSDT = IERC20(usdt);
        oracle = USDTOracleAdapter(oracleAdapter);
        owner = initialOwner;
    }

    function setControls(bool deposits, bool redemptions) external onlyOwner {
        depositsEnabled = deposits;
        redemptionsEnabled = redemptions;
        emit ControlsUpdated(deposits, redemptions);
    }

    function deposit(uint256 usdtAmount) external {
        require(depositsEnabled, "deposits disabled");
        require(usdtAmount > 0, "zero amount");
        require(oracle.isHealthy(), "oracle unhealthy");

        _safeTransferFrom(address(collateralUSDT), msg.sender, address(this), usdtAmount);
        trackerToken.mint(msg.sender, usdtAmount);

        emit Deposited(msg.sender, usdtAmount, usdtAmount);
    }

    function redeem(uint256 trackerAmount) external {
        require(redemptionsEnabled, "redemptions disabled");
        require(trackerAmount > 0, "zero amount");
        require(oracle.isHealthy(), "oracle unhealthy");
        require(
            collateralUSDT.balanceOf(address(this)) >= trackerAmount,
            "insufficient collateral"
        );

        trackerToken.burn(msg.sender, trackerAmount);
        _safeTransfer(address(collateralUSDT), msg.sender, trackerAmount);

        emit Redeemed(msg.sender, trackerAmount, trackerAmount);
    }

    function collateralBalance() external view returns (uint256) {
        return collateralUSDT.balanceOf(address(this));
    }

    function currentUSDTUSDPrice18() external view returns (uint256) {
        return oracle.price18();
    }

    function isOracleHealthy() external view returns (bool) {
        return oracle.isHealthy();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero owner");
        owner = newOwner;
    }

    function _safeTransfer(address token, address to, uint256 amount) internal {
        (bool ok, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, amount));
        require(ok && (data.length == 0 || abi.decode(data, (bool))), "transfer failed");
    }

    function _safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        (bool ok, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount));
        require(ok && (data.length == 0 || abi.decode(data, (bool))), "transferFrom failed");
    }
}
