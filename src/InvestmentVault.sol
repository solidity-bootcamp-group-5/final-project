// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "forge-std/console.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

interface IAavePool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}

interface CErc20 {
    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);

    function balanceOf(address owner) external view returns (uint256 balance);
}

contract InvestmentVault is ERC4626 {
    IAavePool public immutable aavePool;
    IERC20 public immutable usdc;
    IERC20 public immutable aUsdc;
    CErc20 public immutable cUsdc;

    constructor(address underlying, address _aavePool, address _aUsdc, address _cUsdc)
        ERC20("Investment Vault USDC", "VUSDC")
        ERC4626(IERC20(underlying))
    {
        aavePool = IAavePool(_aavePool);
        usdc = IERC20(underlying);
        aUsdc = IERC20(_aUsdc);
        cUsdc = CErc20(_cUsdc);
    }

    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        uint256 aaveAmount = assets / 2;
        uint256 compoundAmount = assets - aaveAmount;

        IERC20(usdc).approve(address(aavePool), assets);
        IERC20(usdc).approve(address(cUsdc), assets);

        aavePool.supply(address(usdc), aaveAmount, address(this), 0);

        cUsdc.mint(compoundAmount);

        return shares;
    }

    function mint(uint256 shares, address receiver) public override returns (uint256) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        IERC20(usdc).approve(address(aavePool), assets);
        aavePool.supply(address(usdc), assets, address(this), 0);

        return assets;
    }

    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);

        aavePool.withdraw(address(usdc), assets, address(this));

        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);

        uint256 aaveAmount = assets / 2;
        uint256 compoundAmount = assets - aaveAmount;

        aavePool.withdraw(address(usdc), aaveAmount, address(this));
        cUsdc.redeemUnderlying(compoundAmount);

        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    function totalAssets() public view override returns (uint256) {
        return aUsdc.balanceOf(address(this));
    }

    function balanceAave() public view returns (uint256) {
        return aUsdc.balanceOf(address(this));
    }

    function balanceCompound() public view returns (uint256) {
        return cUsdc.balanceOf(address(this));
    }
}
