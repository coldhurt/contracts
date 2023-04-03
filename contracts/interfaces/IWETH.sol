// SPDX-License-Identifier: GPL-v3
pragma solidity >=0.8.4;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}
