// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseTest.t.sol";
import "src/CollateralManager.sol";
import "src/LPManager.sol";

contract CollateralManagerTest is BaseTest {
    CollateralManager public testCollateralManager;
    LPManager public testLpManager;

    function setUp() public override {
        super.setUp();
        testCollateralManager = new CollateralManager(address(MDAI));
        testLpManager = new LPManager(IERC20(address(MDAI)), "Test LP", "TLP", address(this));
    }

    function test_constructor() public {
        assertEq(testCollateralManager.owner(), address(this));
    }

    function test_deposit() public {
        uint256 depositAmount = 100 ether;

        vm.startPrank(ALICE);
        MDAI.approve(address(testCollateralManager), depositAmount);
        testCollateralManager.deposit(depositAmount);
        vm.stopPrank();

        (address user, uint256 amount, uint256 lastUpdatedAt) = testCollateralManager.getUserDeposit(ALICE);
        assertEq(user, ALICE);
        assertEq(amount, depositAmount);
        assertEq(lastUpdatedAt, block.timestamp);
        assertEq(testCollateralManager.totalDeposits(), depositAmount);
    }

    function test_deposit_zeroAmount() public {
        vm.startPrank(ALICE);
        MDAI.approve(address(testCollateralManager), 0);
        vm.expectRevert("Deposit amount must be greater than zero");
        testCollateralManager.deposit(0);
        vm.stopPrank();
    }

    function test_withdraw_insufficientBalance() public {
        uint256 depositAmount = 100 ether;
        uint256 withdrawAmount = 150 ether;

        vm.startPrank(ALICE);
        MDAI.approve(address(testCollateralManager), depositAmount);
        testCollateralManager.deposit(depositAmount);

        vm.expectRevert("Insufficient deposit");
        testCollateralManager.withdraw(withdrawAmount);
        vm.stopPrank();
    }

    function test_updateUserDeposit_onlyOwner() public {
        vm.startPrank(ALICE);
        vm.expectRevert();
        testCollateralManager.updateUserDeposit(ALICE, 100 ether, true);
        vm.stopPrank();
    }

    function test_withdrawLosses() public {
        uint256 lossAmount = 50 ether;

        // Setup some collateral
        vm.startPrank(ALICE);
        MDAI.approve(address(testCollateralManager), 100 ether);
        testCollateralManager.deposit(100 ether);
        vm.stopPrank();

        uint256 lpBalanceBefore = MDAI.balanceOf(address(testLpManager));
        testCollateralManager.withdrawLosses(address(testLpManager), lossAmount);
        uint256 lpBalanceAfter = MDAI.balanceOf(address(testLpManager));

        assertEq(lpBalanceAfter - lpBalanceBefore, lossAmount);
    }

    function test_withdrawLosses_onlyOwner() public {
        vm.startPrank(ALICE);
        vm.expectRevert();
        testCollateralManager.withdrawLosses(ALICE, 100 ether);
        vm.stopPrank();
    }

    function test_getUserDeposit_newUser() public {
        (address user, uint256 amount, uint256 lastUpdatedAt) = testCollateralManager.getUserDeposit(JANE);
        assertEq(user, address(0));
        assertEq(amount, 0);
        assertEq(lastUpdatedAt, 0);
    }

    function test_totalDeposits() public {
        assertEq(testCollateralManager.totalDeposits(), 0);

        vm.startPrank(ALICE);
        MDAI.approve(address(testCollateralManager), 100 ether);
        testCollateralManager.deposit(100 ether);
        vm.stopPrank();

        assertEq(testCollateralManager.totalDeposits(), 100 ether);
    }
}
