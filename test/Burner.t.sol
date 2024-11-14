// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Burner} from "../src/Burner.sol";

function calcCreate2Address(address deployer, uint256 salt, bytes32 bytecodeHash) pure returns (address) {
    bytes32 hash = keccak256(
        abi.encodePacked(
            bytes1(0xff),
            deployer,
            salt,
            bytecodeHash
        )
    );
    return address(uint160(uint256(hash)));
}

contract BurnerTest is Test {
    function getParameterizedCreationCode(address callbackTarget, bytes memory callbackData) internal pure returns (bytes memory) {
        return abi.encodePacked(type(Burner).creationCode, abi.encode(callbackTarget, callbackData));
    }

    function _lightBurner(uint256 salt, bytes memory creationCode) internal returns (address burner) {
        assembly {
            burner := create2(0, add(creationCode, 0x20), mload(creationCode), salt)
        }
    }

    function lightBurner(uint256 salt, bytes memory creationCode) internal returns (address) {
        address deployer = address(this);
        address burner = _lightBurner(salt, creationCode);

        require(burner != address(0), "contract was already burned");

        // verify burner deployed the expected bytecode, which is just the INVALID opcode
        bytes memory code = burner.code;
        require(code.length == 1, "burner code length is not 1");
        require(code[0] == 0xfe, "burner opcode is expected to be 0xfe");
        return burner;
    }

    function test_Burner() public {
        address deployer = makeAddr("Create3");
        address callbackTarget = makeAddr("Burner Callback Contract");

        // for testing ensure target is a BurnerCallback
        vm.etch(callbackTarget, type(BurnerCallback).runtimeCode);
        vm.store(callbackTarget, bytes32(uint256(0xdeadbeef)), bytes32(uint256(uint160(callbackTarget))));

        uint256 param1 = 1;
        uint256 param2 = 2;

        // encode burner params
        uint256 salt = 0xcafebabe;
        bytes memory callbackData = abi.encodeWithSignature("onBurn(uint256,uint256)", param1, param2);
        bytes memory creationCode = getParameterizedCreationCode(callbackTarget, callbackData);
        bytes32 bytecodeHash = keccak256(creationCode);
        console.log("burner params:");
        console.log("|- salt              = %x", salt);
        console.log("|- bytecodeHash      = %x", uint256(bytecodeHash));
        console.log("|- deployer          =", deployer);
        console.log("|-------------------");

        // verify burner deployed to expected address
        address calculatedBurnerAddress = calcCreate2Address(deployer, salt, bytecodeHash);

        console.log("|- callback address  =", callbackTarget);
        console.log("|- callback data     = onBurn(uint256(%x), uint256(%x))", param1, param2);
        // console.logBytes(callbackData);
        // console.log("|- burner template creation code =");
        // console.logBytes(type(Burner).creationCode);
        // console.log("|- burner parameterized creation code =");
        // console.logBytes(creationCode);
        console.log("\\_ burner contract   =", calculatedBurnerAddress);
        console.log("");

        vm.startPrank(deployer);

        // burn it (ie. deploy)
        address burner = lightBurner(salt, creationCode);

        // verify burner deployed to the expected address        
        require(burner == calculatedBurnerAddress, "burner address mismatch");

        // lightBurner() will return 0 if the contract was already deployed
        require(_lightBurner(salt, creationCode) == address(0), "doule burn should be impossible");
        vm.stopPrank();
    }
}

contract BurnerCallback {
    function onBurn(uint256 param1, uint256 param2) external payable {
        console.log("onBurn() called:");
        address codeAddr;
        assembly {
            codeAddr := sload(0xdeadbeef)
        }
        console.log("|- burner deployer   =", msg.sender);
        console.log("|- burner contract   =", address(this));
        // console.log("  burner callback   =", SELF); // set SELF = address(this) in constructor if you want to access it
        console.log("\\_ data length       =", msg.data.length - 4);
    }
}
