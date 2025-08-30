// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseTest.t.sol";
import "src/LPManager.sol";

contract LPManagerTest is BaseTest {
    LPManager public lpManager;

    function setUp() public override {
        super.setUp();
        lpManager = new LPManager(IERC20(address(MDAI)), "LP DAI", "LPDAI", OWNER);
    }

    function test_constructor() public {
        assertEq(lpManager.owner(), OWNER);
        assertEq(lpManager.name(), "LP DAI");
        assertEq(lpManager.symbol(), "LPDAI");
        assertEq(lpManager.asset(), address(MDAI));
    }

    function test_deposit_minimumAmount() public {
        uint256 depositAmount = 10 ether;
        
        vm.startPrank(ALICE);
        MDAI.approve(address(lpManager), depositAmount);
        uint256 shares = lpManager.deposit(depositAmount, ALICE);
        vm.stopPrank();

        assertGt(shares, 0);
        assertEq(lpManager.balanceOf(ALICE), shares);
        assertEq(MDAI.balanceOf(address(lpManager)), depositAmount);
    }

    function test_deposit_belowMinimum() public {
        uint256 depositAmount = 5 ether; // Below 10 ether minimum
        
        vm.startPrank(ALICE);
        MDAI.approve(address(lpManager), depositAmount);
        vm.expectRevert("Can't deposit less than 10 DAI");
        lpManager.deposit(depositAmount, ALICE);
        vm.stopPrank();
    }

    function test_deposit_multipleUsers() public {
        uint256 depositAmount = 100 ether;
        
        // Alice deposits
        vm.startPrank(ALICE);
        MDAI.approve(address(lpManager), depositAmount);
        uint256 aliceShares = lpManager.deposit(depositAmount, ALICE);
        vm.stopPrank();

        // Bob deposits
        vm.startPrank(BOB);
        MDAI.approve(address(lpManager), depositAmount);
        uint256 bobShares = lpManager.deposit(depositAmount, BOB);
        vm.stopPrank();

        assertEq(lpManager.balanceOf(ALICE), aliceShares);
        assertEq(lpManager.balanceOf(BOB), bobShares);
        assertEq(MDAI.balanceOf(address(lpManager)), depositAmount * 2);
    }

    function test_withdraw() public {
        uint256 depositAmount = 100 ether;
        uint256 withdrawAmount = 50 ether;
        
        // First deposit
        vm.startPrank(ALICE);
        MDAI.approve(address(lpManager), depositAmount);
        lpManager.deposit(depositAmount, ALICE);
        
        // Then withdraw
        uint256 balanceBefore = MDAI.balanceOf(ALICE);
        uint256 sharesBurned = lpManager.withdraw(withdrawAmount, ALICE, ALICE);
        uint256 balanceAfter = MDAI.balanceOf(ALICE);
        vm.stopPrank();

        assertGt(sharesBurned, 0);
        assertEq(balanceAfter - balanceBefore, withdrawAmount);
    }

    function test_withdraw_shares() public {
        uint256 depositAmount = 100 ether;
        
        vm.startPrank(ALICE);
        MDAI.approve(address(lpManager), depositAmount);
        uint256 shares = lpManager.deposit(depositAmount, ALICE);
        
        uint256 balanceBefore = MDAI.balanceOf(ALICE);
        uint256 assetsReceived = lpManager.redeem(shares / 2, ALICE, ALICE);
        uint256 balanceAfter = MDAI.balanceOf(ALICE);
        vm.stopPrank();

        assertGt(assetsReceived, 0);
        assertEq(balanceAfter - balanceBefore, assetsReceived);
    }

    function test_totalAssets() public {
        uint256 depositAmount = 100 ether;
        
        vm.startPrank(ALICE);
        MDAI.approve(address(lpManager), depositAmount);
        lpManager.deposit(depositAmount, ALICE);
        vm.stopPrank();

        assertEq(lpManager.totalAssets(), depositAmount);
    }

    function test_totalAssets_withLockedAmount() public {
        uint256 depositAmount = 100 ether;
        uint256 lockedAmount = 30 ether;
        
        vm.startPrank(ALICE);
        MDAI.approve(address(lpManager), depositAmount);
        lpManager.deposit(depositAmount, ALICE);
        vm.stopPrank();

        // Lock some amount
        vm.prank(OWNER);
        lpManager.increaseLockedAmount(lockedAmount);

        assertEq(lpManager.totalAssets(), depositAmount - lockedAmount);
    }





    function test_increaseLockedAmount_onlyOwner() public {
        vm.startPrank(ALICE);
        vm.expectRevert();
        lpManager.increaseLockedAmount(100 ether);
        vm.stopPrank();
    }

    function test_decreaseLockedAmount_onlyOwner() public {
        vm.startPrank(ALICE);
        vm.expectRevert();
        lpManager.decreaseLockedAmount(100 ether);
        vm.stopPrank();
    }

    function test_withdrawLosses() public {
        uint256 lossAmount = 50 ether;
        
        // Setup some assets in the LP manager
        vm.startPrank(ALICE);
        MDAI.approve(address(lpManager), 100 ether);
        lpManager.deposit(100 ether, ALICE);
        vm.stopPrank();

        uint256 recipientBalanceBefore = MDAI.balanceOf(JANE);
        vm.prank(OWNER);
        lpManager.withdrawLosses(JANE, lossAmount);
        uint256 recipientBalanceAfter = MDAI.balanceOf(JANE);
        
        assertEq(recipientBalanceAfter - recipientBalanceBefore, lossAmount);
    }

    function test_withdrawLosses_onlyOwner() public {
        vm.startPrank(ALICE);
        vm.expectRevert();
        lpManager.withdrawLosses(ALICE, 100 ether);
        vm.stopPrank();
    }

    function test_convertToShares() public {
        uint256 assets = 100 ether;
        uint256 shares = lpManager.convertToShares(assets);
        assertGt(shares, 0);
    }

    function test_convertToAssets() public {
        uint256 shares = 100 ether;
        uint256 assets = lpManager.convertToAssets(shares);
        assertGt(assets, 0);
    }

    function test_previewDeposit() public {
        uint256 assets = 100 ether;
        uint256 shares = lpManager.previewDeposit(assets);
        assertGt(shares, 0);
    }

    function test_previewWithdraw() public {
        uint256 assets = 100 ether;
        uint256 shares = lpManager.previewWithdraw(assets);
        assertGt(shares, 0);
    }

    function test_previewMint() public {
        uint256 shares = 100 ether;
        uint256 assets = lpManager.previewMint(shares);
        assertGt(assets, 0);
    }

    function test_previewRedeem() public {
        uint256 shares = 100 ether;
        uint256 assets = lpManager.previewRedeem(shares);
        assertGt(assets, 0);
    }

    function test_maxDeposit() public {
        uint256 maxDeposit = lpManager.maxDeposit(ALICE);
        assertGt(maxDeposit, 0);
    }

    function test_maxMint() public {
        uint256 maxMint = lpManager.maxMint(ALICE);
        assertGt(maxMint, 0);
    }

    function test_maxWithdraw() public {
        uint256 maxWithdraw = lpManager.maxWithdraw(ALICE);
        assertEq(maxWithdraw, 0); // No shares initially
    }

    function test_maxRedeem() public {
        uint256 maxRedeem = lpManager.maxRedeem(ALICE);
        assertEq(maxRedeem, 0); // No shares initially
    }
}
