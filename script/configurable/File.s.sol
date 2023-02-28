// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-std/Script.sol";

import {IConfigurable} from "src/configurable/IConfigurable.sol";

// TODO: (Untested) Example script to file a configuration to a configurable
//       contract instance.

// TODO: Maybe easier with just shell script using cast?

contract Configurable_File_Script is Script {
    IConfigurable configurable;

    bytes32 file;
    bytes value;

    function setUp() public {
        // TODO: Should read contract address from env?
        configurable = IConfigurable(address(0xcafe));

        // TODO: Should read (file, value) tuple from somewhere?
        file = "version";
        value = abi.encodePacked("0.0.1");
    }

    function run() public {
        vm.broadcast();

        configurable.file(file, value);
    }
}
