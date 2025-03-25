// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {InvestmentVault} from "src/InvestmentVault.sol";

contract InvestmnentVaultTest is Test {
    InvestmentVault public vault;

    address OWNER = makeAddr("Owner");
    address USER1 = makeAddr("User1");
    address USER2 = makeAddr("User2");

    IERC20 usdc; // Interface instance for USDC

    address usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC contract address on Ethereum Mainnet
    address usdcWhale = 0x37305B1cD40574E4C5Ce33f8e8306Be057fD7341;

    uint256 constant INITIAL_USER1_BALANCE_ETH = 20 ether;
    uint256 constant INITIAL_USER2_BALANCE_ETH = 10 ether;

    uint256 mainnetFork;

    function setUp() public virtual {
        vm.label(OWNER, "Owner");
        vm.label(USER1, "User1");
        vm.label(USER2, "User2");

        mainnetFork = vm.createFork("https://eth.llamarpc.com");

        vm.label(address(vault), "InvestmentVault");

        usdc = IERC20(usdcAddress);

        vm.startPrank(OWNER);
        vault = new InvestmentVault(address(usdc));
        vm.stopPrank();
    }

    function test_mint() public {
        assertEq(vault.balanceOf(USER1), 0);
        vault.mint(USER1, 100);
        assertEq(vault.balanceOf(USER1), 100);
    }

    function test_total() public view {
        assertEq(vault.totalSupply(), 0);
    }

    function test_deposit() public {
        vm.selectFork(mainnetFork);
        vm.prank(usdcWhale);
        usdc.transfer(USER1, 1000);
        assertEq(usdc.balanceOf(USER1), 1000);
    }

    function test_usdc() public {
        vm.selectFork(mainnetFork);
        assertEq(usdc.balanceOf(USER1), 0);
    }
}
