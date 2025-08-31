// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MockV3Aggregator {
    int256 private answer;
    uint8 private decimals_;

    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals_ = _decimals;
        answer = _initialAnswer;
    }

    function updateAnswer(int256 _answer) external {
        answer = _answer;
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256, uint256, uint256 updatedAt, uint80 answeredInRound)
    {
        return (0, answer, 0, block.timestamp, 0);
    }

    function decimals() external view returns (uint8) {
        return decimals_;
    }
}
