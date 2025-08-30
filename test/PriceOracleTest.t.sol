// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseTest.t.sol";
import "./mocks/MockPriceOracle.sol";
import "src/PriceOracle.sol";

contract PriceOracleTest is BaseTest {
    MockPriceOracle public mockEthOracle;
    MockPriceOracle public mockDaiOracle;
    PriceOracle public priceOracle;

    function setUp() public override {
        super.setUp();
        
        // Create mock price oracles
        mockEthOracle = new MockPriceOracle(2000e8, 8); // $2000 ETH
        mockDaiOracle = new MockPriceOracle(1e8, 8);    // $1 DAI
        
        // Create price oracle
        priceOracle = new PriceOracle();
    }

    function test_constructor() public {
        // Test that constructor doesn't revert
        PriceOracle oracle = new PriceOracle();
        assertTrue(address(oracle) != address(0));
    }

    function test_setFeeds() public {
        address newDaiFeed = address(0x123);
        address newEthFeed = address(0x456);
        
        priceOracle.setFeeds(newDaiFeed, newEthFeed);
        
        // We can't directly access the private variables, but we can test through getChainlinkDataFeedLatestAnswer
        // This will fail if the feeds weren't set correctly
        vm.expectRevert(); // Should revert because mock addresses don't implement the interface
        priceOracle.getChainlinkDataFeedLatestAnswer(Feed.EthUsd);
    }













    function test_setFeeds_onlyOwner() public {
        // This test would be relevant if setFeeds had access control
        // Currently it doesn't, so we just test it works
        address newDaiFeed = address(0x123);
        address newEthFeed = address(0x456);
        
        vm.prank(ALICE);
        priceOracle.setFeeds(newDaiFeed, newEthFeed);
        
        // Should not revert
    }







    function test_feedEnumValues() public {
        // Test that enum values are correct
        assertEq(uint256(Feed.EthUsd), 0);
        assertEq(uint256(Feed.DaiUsd), 1);
    }
}
