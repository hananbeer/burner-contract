// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Burner {
    constructor(address target, bytes memory data) {
        assembly {
            sstore(0xdeadbeef, address())
            pop(delegatecall(gas(), target, add(data, 0x20), mload(data), 0x00, 0x00))
            // optionally deploy the INVALID (0xfe) opcode instead of STOP (0x00)
            mstore(0x00, 0xfe)
            return(0x1f, 0x01)
        }
    }
}
