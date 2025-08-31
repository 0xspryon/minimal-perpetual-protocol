// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseTest.t.sol";
import "src/CollateralManager.sol";

contract CollateralManagerTest is BaseTest {
    function test_depositRevertsOnZeroAmount() public {
        vm.startPrank(ALICE);
        MDAI.approve(address(collateralManager), type(uint256).max);
        vm.expectRevert("Deposit amount must be greater than zero");
        collateralManager.deposit(0);
        vm.stopPrank();
    }

    function test_withdrawHappyPath() public {
        vm.startPrank(ALICE);
        MDAI.approve(address(collateralManager), type(uint256).max);
        collateralManager.deposit(20 ether);

        uint256 aliceBalanceBefore = MDAI.balanceOf(ALICE);
        collateralManager.withdraw(10 ether);

        (, uint256 depositAfter,) = collateralManager.getUserDeposit(ALICE);
        assertEq(depositAfter, 10 ether);
        assertEq(MDAI.balanceOf(ALICE), aliceBalanceBefore + 10 ether);
        vm.stopPrank();
    }

    function test_withdrawRevertsIfTooMuch() public {
        vm.startPrank(ALICE);
        MDAI.approve(address(collateralManager), type(uint256).max);
        collateralManager.deposit(5 ether);
        vm.expectRevert("Insufficient deposit");
        collateralManager.withdraw(10 ether);
        vm.stopPrank();
    }

    function test_onlyOwnerCanUpdateUserDeposit() public {
        vm.startPrank(ALICE);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ALICE));
        collateralManager.updateUserDeposit(ALICE, 1 ether, true);
        vm.stopPrank();
    }

    function test_ownerCanUpdateUserDeposit() public {
        vm.startPrank(OWNER);
        collateralManager.updateUserDeposit(ALICE, 1 ether, true);
        vm.stopPrank();
    }

    function test_ownerCanWithdrawLosses() public {
        vm.startPrank(ALICE);
        MDAI.approve(address(collateralManager), type(uint256).max);
        collateralManager.deposit(5 ether);
        vm.stopPrank();

        // OWNER withdraws losses
        vm.startPrank(OWNER);
        collateralManager.withdrawLosses(OWNER, 1 ether);
        vm.stopPrank();

        assertEq(MDAI.balanceOf(OWNER), 1 ether);
    }
}
