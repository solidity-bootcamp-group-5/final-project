// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {InvestmentVault} from "src/InvestmentVault.sol";

// NOTE INTERFACE FOR COMPOUND V3 - AT 0xc3d688B66703497DAA19211EEdff47f25384cdc3
interface ICUsdc is IERC20 {
    function supply(address asset, uint256 amount) external;
    function withdraw(address asset, uint256 amount) external;
}

contract InvestmentVaultTest is Test {
    InvestmentVault public vault;

    address OWNER = makeAddr("Owner");
    address USER1 = makeAddr("User1");
    address USER2 = makeAddr("User2");

    IERC20 usdc;

    address usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address usdcWhale = 0x37305B1cD40574E4C5Ce33f8e8306Be057fD7341;
    address aavePool = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
    address aUSDC = 0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c;
    address cUSDC = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;

    uint256 constant INITIAL_USER1_BALANCE_ETH = 20 ether;
    uint256 constant INITIAL_USER2_BALANCE_ETH = 10 ether;

    uint256 mainnetFork;

    function setUp() public virtual {
        vm.label(OWNER, "Owner");
        vm.label(USER1, "User1");
        vm.label(USER2, "User2");

        vm.deal(usdcWhale, 1 ether);
        vm.deal(USER1, 1 ether);

        mainnetFork = vm.createFork("https://eth.llamarpc.com", 22_122_000);

        vm.selectFork(mainnetFork);

        usdc = IERC20(usdcAddress);

        vm.startPrank(OWNER);
        vault = new InvestmentVault(address(usdc), aavePool, aUSDC, cUSDC);
        vm.stopPrank();

        vm.label(address(vault), "InvestmentVault");
    }

    function test_total() public view {
        assertEq(vault.totalSupply(), 0);
    }

    function test_deposit() public {
        vm.selectFork(mainnetFork);
        vm.prank(usdcWhale);
        uint256 amount = 1000 * 10 ** 6;

        usdc.transfer(USER1, amount);
        assertEq(usdc.balanceOf(USER1), amount);
        vm.startPrank(USER1);
        usdc.approve(address(vault), amount);
        assertEq(vm.activeFork(), mainnetFork);
        assertEq(vault.balanceAave(), 0);
        assertEq(vault.balanceCompound(), 0);
        vault.deposit(amount, USER1);
        assertEq(usdc.balanceOf(USER1), 0);
        assertEq(vault.balanceOf(USER1), amount);
        assertEq(vault.balanceAave(), amount / 2);
        assertEq(vault.balanceCompound(), 2_018_808_063_649);
        vm.stopPrank();
    }

    function test_usdc() public {
        vm.selectFork(mainnetFork);
        assertEq(usdc.balanceOf(USER1), 0);
    }

    function test_vaultBalance() public {
        vm.selectFork(mainnetFork);
        assertEq(vault.balanceAave(), 0);
        assertEq(vault.balanceCompound(), 0);
    }

    // NOTE USE COMPOUND V3 INSTEAD
    function test_CompoundV3() public {
        ICUsdc cUsdcV3 = ICUsdc(0xc3d688B66703497DAA19211EEdff47f25384cdc3);
        uint256 amount = 100e6;
        deal(usdcAddress, USER1, amount, true);

        vm.startPrank(USER1);
        usdc.approve(address(cUsdcV3), amount);
        cUsdcV3.supply(usdcAddress, amount);
        vm.stopPrank();

        console.log(cUsdcV3.balanceOf(USER1));

        skip(180 days);

        console.log(cUsdcV3.balanceOf(USER1));
    }
}
