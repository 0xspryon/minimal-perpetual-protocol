// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseTest.t.sol";
import "src/LPManager.sol";

contract LPManagerTest is BaseTest {
    function test_depositRevertsIfLessThan10Dai() public {
        LPManager lp = posManager.lpManager();

        vm.startPrank(ALICE);
        MDAI.approve(address(lp), type(uint256).max);
        vm.expectRevert("Can't deposit less than 10 DAI");
        lp.deposit(1 ether, ALICE);
        vm.stopPrank();
    }

    function test_onlyOwnerCanIncreaseLockedAmount() public {
        LPManager lp = posManager.lpManager();

        vm.startPrank(ALICE);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ALICE));
        lp.increaseLockedAmount(10 ether);
        vm.stopPrank();
    }

    function test_ownerCanIncreaseAndDecreaseLockedAmount() public {
        LPManager lp = posManager.lpManager();

        vm.startPrank(OWNER);
        lp.increaseLockedAmount(50 ether);
        lp.decreaseLockedAmount(20 ether);
        vm.stopPrank();

        assertEq(lp.lockedAmount(), 30 ether);
    }

    function test_onlyOwnerCanWithdrawLosses() public {
        LPManager lp = posManager.lpManager();

        vm.startPrank(ALICE);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ALICE));
        lp.withdrawLosses(ALICE, 1 ether);
        vm.stopPrank();
    }

    function test_lpManagerPreviewFunctions() public {
        LPManager lp = posManager.lpManager();

        vm.startPrank(ALICE);
        MDAI.approve(address(lp), type(uint256).max);

        uint256 assets = 100 ether;
        uint256 previewedShares = lp.previewDeposit(assets);

        lp.deposit(assets, ALICE);

        uint256 actualShares = lp.balanceOf(ALICE);
        assertEq(actualShares, previewedShares);

        uint256 previewedAssets = lp.previewRedeem(actualShares);
        assertEq(previewedAssets, assets);
        vm.stopPrank();
    }

    function test_lpManagerMaxFunctions() public {
        LPManager lp = posManager.lpManager();

        vm.startPrank(ALICE);
        MDAI.approve(address(lp), type(uint256).max);
        lp.deposit(500 ether, ALICE);
        vm.stopPrank();

        uint256 maxDeposit = lp.maxDeposit(ALICE);
        uint256 maxMint = lp.maxMint(ALICE);
        uint256 maxWithdraw = lp.maxWithdraw(ALICE);
        uint256 maxRedeem = lp.maxRedeem(ALICE);

        assertTrue(maxDeposit > 0);
        assertTrue(maxMint > 0);
        assertTrue(maxWithdraw > 0);
        assertTrue(maxRedeem > 0);
    }

    function test_lpManagerConvertToFunctions() public {
        LPManager lp = posManager.lpManager();

        vm.startPrank(ALICE);
        MDAI.approve(address(lp), type(uint256).max);
        lp.deposit(100 ether, ALICE);
        vm.stopPrank();

        uint256 shares = lp.balanceOf(ALICE);

        uint256 convertedAssets = lp.convertToAssets(shares);
        uint256 convertedShares = lp.convertToShares(100 ether);

        assertEq(convertedAssets, 100 ether);
        assertEq(convertedShares, shares);
    }

    function test_lpManagerAssetShareRelationship() public {
        LPManager lp = posManager.lpManager();

        vm.startPrank(ALICE);
        MDAI.approve(address(lp), type(uint256).max);

        lp.deposit(100 ether, ALICE);
        uint256 sharesAfterFirst = lp.balanceOf(ALICE);

        lp.deposit(200 ether, ALICE);
        uint256 sharesAfterSecond = lp.balanceOf(ALICE);

        assertTrue(sharesAfterSecond > sharesAfterFirst);
        assertEq(lp.totalSupply(), sharesAfterSecond);
        vm.stopPrank();
    }
}
