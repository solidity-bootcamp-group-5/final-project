// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import {InvestmnentVaultTest, console, IERC20} from "../InvestmentVault.t.sol";

contract InvestmnentVaultTestZe is InvestmnentVaultTest {
    function test_DepositAndWithdraw() public {
        deal(address(usdc), USER1, 1000e6, true);
        deal(address(usdc), USER2, 1000e6, true);

        vm.startPrank(USER1);
        usdc.approve(address(vault), 500e6);
        vault.deposit(500e6, USER1);
        vm.stopPrank();

        vm.startPrank(USER2);
        usdc.approve(address(vault), 500e6);
        vault.deposit(500e6, USER2);
        vm.stopPrank();

        skip(180 days);

        vm.startPrank(USER1);
        vault.redeem(vault.balanceOf(USER1), USER1, USER1);
        vm.stopPrank();

        vm.startPrank(USER2);
        vault.redeem(vault.balanceOf(USER2), USER2, USER2);
        vm.stopPrank();

        console.log(usdc.balanceOf(USER1));
        console.log(usdc.balanceOf(USER2));
    }
}
