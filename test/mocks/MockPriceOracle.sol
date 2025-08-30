// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "smartcontractkit-chainlink-evm/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockPriceOracle is AggregatorV3Interface {
    int256 private _price;
    uint8 private _decimals;
    uint256 private _timestamp;
    uint80 private _roundId;

    constructor(int256 initialPrice, uint8 decimals_) {
        _price = initialPrice;
        _decimals = decimals_;
        _timestamp = block.timestamp;
        _roundId = 1;
    }

    function setPrice(int256 newPrice) external {
        _price = newPrice;
        _timestamp = block.timestamp;
        _roundId++;
    }

    function setPriceWithTimestamp(int256 newPrice, uint256 timestamp) external {
        _price = newPrice;
        _timestamp = timestamp;
        _roundId++;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function description() external pure override returns (string memory) {
        return "Mock Price Oracle";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(uint80 _id) external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (_id, _price, _timestamp, _timestamp, _id);
    }

    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (_roundId, _price, _timestamp, _timestamp, _roundId);
    }
}
