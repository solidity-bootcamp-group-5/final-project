// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {InvestmentVault} from "src/InvestmentVault.sol";

contract InvestmnentVaultTest is Test {
    InvestmentVault public vault;

    address OWNER = makeAddr("Owner");
    address USER1 = makeAddr("User1");
    address USER2 = makeAddr("User2");

    uint256 constant INITIAL_USER1_BALANCE_ETH = 20 ether;
    uint256 constant INITIAL_USER2_BALANCE_ETH = 10 ether;

    function setUp() public virtual {
        vm.label(OWNER, "Owner");
        vm.label(USER1, "User1");
        vm.label(USER2, "User2");

        vm.startPrank(OWNER);
        vault = new InvestmentVault(address(OWNER));
        vm.stopPrank();

        vm.label(address(vault), "InvestmentVault");

        vm.stopPrank();
    }

    function test_mint() public {
        vault.mint(USER1, 100);
        assertEq(vault.balanceOf(USER1), 100);
    }
}
