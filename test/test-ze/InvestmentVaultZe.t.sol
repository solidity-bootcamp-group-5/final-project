// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import {InvestmentVaultTest, console, IERC20} from "../InvestmentVault.t.sol";

contract InvestmentVaultTestZe is InvestmentVaultTest {
    function test_DepositAndRedeem(uint256 amount1, uint256 amount2) public {
        deal(address(usdc), USER1, 1000e6, true);
        deal(address(usdc), USER2, 1000e6, true);

        amount1 = bound(amount1, 1e6, 1000e6);
        amount2 = bound(amount2, 1e6, 1000e6);

        vm.startPrank(USER1);
        usdc.approve(address(vault), amount1);
        vault.deposit(amount1, USER1);
        vm.stopPrank();

        vm.startPrank(USER2);
        usdc.approve(address(vault), amount2);
        vault.deposit(amount2, USER2);
        vm.stopPrank();

        skip(180 days);

        vm.startPrank(USER1);
        vault.redeem(vault.balanceOf(USER1), USER1, USER1);
        vm.stopPrank();

        vm.startPrank(USER2);
        vault.redeem(vault.balanceOf(USER2), USER2, USER2);
        vm.stopPrank();

        assertGt(usdc.balanceOf(USER1), 1000e6);
        assertGt(usdc.balanceOf(USER2), 1000e6);
    }

    function test_MintAndWithdraw(uint256 amount1, uint256 amount2) public {
        deal(address(usdc), USER1, 1000e6, true);
        deal(address(usdc), USER2, 1000e6, true);

        amount1 = bound(amount1, 1e6, 1000e6);
        amount2 = bound(amount2, 1e6, 1000e6);

        uint256 sharesToMint = vault.convertToShares(amount1);

        vm.startPrank(USER1);
        usdc.approve(address(vault), amount1);
        vault.mint(sharesToMint, USER1);
        vm.stopPrank();

        sharesToMint = vault.convertToShares(amount2);

        vm.startPrank(USER2);
        usdc.approve(address(vault), amount2);
        vault.mint(sharesToMint, USER2);
        vm.stopPrank();

        skip(180 days);

        vm.startPrank(USER1);
        vault.withdraw(vault.convertToAssets(vault.balanceOf(USER1)), USER1, USER1);
        vm.stopPrank();

        vm.startPrank(USER2);
        vault.withdraw(vault.convertToAssets(vault.balanceOf(USER2)), USER2, USER2);
        vm.stopPrank();

        assertGt(usdc.balanceOf(USER1), 1000e6);
        assertGt(usdc.balanceOf(USER2), 1000e6);
    }
}
