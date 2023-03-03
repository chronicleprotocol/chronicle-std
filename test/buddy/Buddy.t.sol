// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {IBuddyTest} from "./IBuddyTest.sol";
import {IBuddyInvariantTest} from "./IBuddyInvariantTest.sol";

import {Buddy} from "src/buddy/Buddy.sol";

contract BuddyInstance is Buddy {}

contract BuddyTest is IBuddyTest {
    function setUp() public {
        setUp(new BuddyInstance());
    }
}

contract BuddyInvariantTest is IBuddyInvariantTest {
    function setUp() public {
        setUp(new BuddyInstance());
    }
}
