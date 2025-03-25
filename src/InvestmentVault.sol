// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

interface IAavePool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}

contract InvestmentVault is ERC4626 {
    IAavePool public immutable aavePool;
    IERC20 public immutable usdc;
    IERC20 public immutable aUsdc;

    constructor(address underlying, address _aavePool, address _aUsdc)
        ERC20("Investment Vault USDC", "VUSDC")
        ERC4626(IERC20(underlying))
    {
        aavePool = IAavePool(_aavePool);
        usdc = IERC20(underlying);
        aUsdc = IERC20(_aUsdc);
    }

    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        IERC20(usdc).approve(address(aavePool), assets);
        aavePool.supply(address(usdc), assets, address(this), 0);

        return shares;
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

    function totalAssets() public view override returns (uint256) {
        return aUsdc.balanceOf(address(this));
    }

    function balance() public view returns (uint256) {
        return aUsdc.balanceOf(address(this));
    }
}
