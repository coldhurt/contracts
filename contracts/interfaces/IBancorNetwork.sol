// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4;

interface IBancorNetwork {
    function convertByPath(
        address[] memory _path,
        uint256 _amount,
        uint256 _minReturn,
        address payable _beneficiary,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) external payable returns (uint256);
}
