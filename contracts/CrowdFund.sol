//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CrowdToken is ERC20 {
    constructor() ERC20("Crowd Token", "CT") {
        _mint(msg.sender, 10000);
    }
}

contract Crowd {
    mapping(address => uint) public values;
    address[] public users;
    uint public immutable duration;
    uint public immutable startAt;
    uint public endAt;
    IERC20 public immutable tokenAddr;
    uint public immutable minValue;

    address payable public owner;

    constructor(IERC20 _tokenAddr, uint _minValue, uint _duration) {
        tokenAddr = _tokenAddr;
        minValue = _minValue;
        startAt = block.timestamp;
        duration = _duration;
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");
        _;
    }

    modifier notExpired() {
        require(startAt + duration > block.timestamp, "expired");
        _;
    }

    modifier hasExpired() {
        require(startAt + duration < block.timestamp, "not expired");
        _;
    }

    modifier notEnded() {
        require(endAt == 0, "ended");
        _;
    }

    function _recordValue(address addr) internal notEnded notExpired {
        require(msg.value > minValue, "ETH < minValue");
        if (values[addr] == 0) {
            users.push(addr);
        }
        values[addr] += msg.value;
    }

    receive() external payable {
        _recordValue(msg.sender);
    }

    fallback() external payable {
        _recordValue(msg.sender);
    }

    function end() external onlyOwner notEnded hasExpired {
        uint totalValue = address(this).balance;
        uint tokenTotal = getTotalToken();
        for (uint i = 0; i < users.length; i++) {
            address addr = users[i];
            tokenAddr.transfer(addr, (values[addr] / totalValue) * tokenTotal);
        }
        endAt = block.timestamp;
    }

    function withdraw() external onlyOwner {
        require(endAt != 0, "not ended");
        owner.transfer(address(this).balance);
    }

    function getTotalToken() public view returns (uint) {
        return tokenAddr.balanceOf(address(this));
    }
}
