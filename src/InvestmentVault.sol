// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

interface IAavePool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
}

contract InvestmentVault is ERC4626 {
    IAavePool public immutable aavePool;
    IERC20 public immutable usdc;

    constructor(address underlying, address _aavePool) ERC20("Investment Vault USDC", "VUSDC") ERC4626(IERC20(underlying)) {
        aavePool = IAavePool(_aavePool);
        usdc = IERC20(underlying);
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
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
}
