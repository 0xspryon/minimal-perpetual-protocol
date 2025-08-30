// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

enum PositionType {
    LONG,
    SHORT
}

struct Position {
    uint256 size;
    address owner;
    uint256 id;
    uint256 openedAt;
    uint256 indexTokenPrice;
    uint256 indexTokenSize;
    uint256 leverage;
    PositionType positionType;
}
