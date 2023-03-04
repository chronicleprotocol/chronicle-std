// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.16;

import {IAuthTest} from "./IAuthTest.sol";
import {IAuthInvariantTest} from "./IAuthInvariantTest.sol";

import {Auth} from "src/auth/Auth.sol";

contract AuthInstance is Auth {}

contract AuthTest is IAuthTest {
    function setUp() public {
        setUp(new AuthInstance());
    }
}

contract AuthInvariantTest is IAuthInvariantTest {
    function setUp() public {
        setUp(new AuthInstance());
    }
}
