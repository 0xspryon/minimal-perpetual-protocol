// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseTest.t.sol";
import "src/PositionManager.sol";
import "src/interfaces/IPosition.sol";
import "./mocks/MockV3Aggregator.sol";

contract PositionManagerTest is BaseTest {
    MockV3Aggregator ethFeed;
    MockV3Aggregator daiFeed;

    function setUp() public override {
        super.setUp();

        // Deploy mock price feeds
        ethFeed = new MockV3Aggregator(8, 2000e8); // ETH/USD at $2000, 8 decimals
        daiFeed = new MockV3Aggregator(18, 1e18); // DAI/USD at $1, 18 decimals

        vm.prank(OWNER);
        posManager.setFeeds(address(daiFeed), address(ethFeed));
    }

    function test_cannotOpenPositionWithTooHighLeverage() public {
        vm.startPrank(ALICE);
        MDAI.approve(address(collateralManager), type(uint256).max);
        collateralManager.deposit(100 ether);

        vm.expectRevert("Can't leverage more than maximum leverage");
        posManager.openPosition(6, PositionType.LONG);
        vm.stopPrank();
    }
}
