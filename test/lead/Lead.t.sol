// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {ILeadTest} from "./ILeadTest.sol";
import {ILeadInvariantTest} from "./ILeadInvariantTest.sol";

import {Lead} from "src/lead/Lead.sol";
import {Auth} from "src/auth/Auth.sol";

contract LeadInstance is Lead, Auth {
    constructor(address initialAuthed) Auth(initialAuthed) {}

    function lead_auth() internal override(Lead) auth {}
}

contract LeadTest is ILeadTest {
    function setUp() public {
        setUp(new LeadInstance(address(this)));
    }
}

contract LeadInvariantTest is ILeadInvariantTest {
    function setUp() public {
        setUp(new LeadInstance(address(this)));
    }
}

