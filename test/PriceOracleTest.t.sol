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
        // Warp to a future timestamp to avoid the 30-minute staleness check
        vm.warp(block.timestamp + 1 hours);
        
        // Create proper mock feeds that implement the Chainlink interface
        MockPriceOracle newDaiFeed = new MockPriceOracle(1e8, 8);  // $1 DAI
        MockPriceOracle newEthFeed = new MockPriceOracle(2000e8, 8); // $2000 ETH
        
        priceOracle.setFeeds(address(newDaiFeed), address(newEthFeed));
        
        // Now we can test that the feeds were set correctly by calling getChainlinkDataFeedLatestAnswer
        // This should not revert since we're using proper mock contracts
        (int256 ethPrice, uint256 ethPrecision) = priceOracle.getChainlinkDataFeedLatestAnswer(Feed.EthUsd);
        (int256 daiPrice, uint256 daiPrecision) = priceOracle.getChainlinkDataFeedLatestAnswer(Feed.DaiUsd);
        
        // Verify the prices match our mock values
        assertEq(ethPrice, 2000e8);
        assertEq(daiPrice, 1e8);
        assertEq(ethPrecision, 8);
        assertEq(daiPrecision, 8);
    }













    function test_setFeeds_onlyOwner() public {
        // This test would be relevant if setFeeds had access control
        // Currently it doesn't, so we just test it works
        // Create proper mock feeds to avoid interface issues
        MockPriceOracle newDaiFeed = new MockPriceOracle(1e8, 8);
        MockPriceOracle newEthFeed = new MockPriceOracle(2000e8, 8);
        
        vm.prank(ALICE);
        priceOracle.setFeeds(address(newDaiFeed), address(newEthFeed));
        
        // Should not revert
    }







    function test_feedEnumValues() public pure {
        // Test that enum values are correct
        // Explicitly test each enum value to ensure they match expected values
        uint256 ethUsdValue = uint256(Feed.EthUsd);
        uint256 daiUsdValue = uint256(Feed.DaiUsd);
        
        require(ethUsdValue == 0, "Feed.EthUsd should equal 0");
        require(daiUsdValue == 1, "Feed.DaiUsd should equal 1");
    }
}
