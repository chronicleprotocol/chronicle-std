// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IAuthTest} from "./IAuthTest.sol";
import {IAuthInvariantTest} from "./IAuthInvariantTest.sol";

import {Auth} from "src/auth/Auth.sol";

contract AuthInstance is Auth {
    constructor(address initialAuthed) Auth(initialAuthed) {}
}

contract AuthTest is IAuthTest {
    function setUp() public {
        setUp(new AuthInstance(address(this)));
    }
}

contract AuthInvariantTest is IAuthInvariantTest {
    function setUp() public {
        setUp(new AuthInstance(address(this)));
    }
}
