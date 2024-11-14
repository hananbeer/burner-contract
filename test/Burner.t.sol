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

    function lightBurner(address deployer, uint256 salt, address callbackTarget, bytes memory callbackData) internal {
        vm.startPrank(deployer);
        bytes32 bytecodeHash = keccak256(getParameterizedCreationCode(callbackTarget, callbackData));
        address calculatedBurnerAddress = calcCreate2Address(deployer, salt, bytecodeHash);
        Burner burner = new Burner{salt: bytes32(salt)}(callbackTarget, callbackData);
        require(address(burner) == calculatedBurnerAddress, "Burner address mismatch");
        require(address(burner).code.length == 1, "Burner code length is not 1");
        vm.stopPrank();

        console.log("burner deployed at:", address(burner));
    }

    function test_Burner() public {
        // address deployer = address(this);
        address deployer = makeAddr("Create3");
        console.log("burner deployer address:", deployer);

        address callbackTarget = makeAddr("Burner Callback Contract");
        console.log("burner target address:", callbackTarget);

        // ensure target has the callback
        vm.etch(callbackTarget, type(BurnerCallback).runtimeCode);

        // encode burner params
        uint256 salt = 0xcafebabe;
        bytes memory callbackData = abi.encodeWithSignature("onBurn(uint256,uint256)", 1, 2);

        lightBurner(deployer, salt, callbackTarget, callbackData);
    }
}

contract BurnerCallback {
    function onBurn(uint256 param1, uint256 param2) external payable {
        console.log("onBurn() called from %s with %s bytes of additional data", msg.sender, msg.data.length - 4);
    }
}
