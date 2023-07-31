// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {ITollTest} from "./ITollTest.sol";
import {ITollInvariantTest} from "./ITollInvariantTest.sol";

import {Toll} from "src/toll/Toll.sol";
import {Auth} from "src/auth/Auth.sol";

contract TollInstance is Toll, Auth {
    constructor(address initialAuthed) Auth(initialAuthed) {}

    function toll_auth() internal override(Toll) auth {}
}

contract TollTest is ITollTest {
    function setUp() public {
        setUp(new TollInstance(address(this)));
    }
}

contract TollInvariantTest is ITollInvariantTest {
    function setUp() public {
        setUp(new TollInstance(address(this)));
    }
}
