// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";

import {ILead} from "src/lead/ILead.sol";
import {IAuth} from "src/auth/IAuth.sol";

/**
 * @notice Provides ILead Unit Tests.
 */
abstract contract ILeadTest is Test {
    ILead lead;

    event LeadGranted(address indexed caller, address indexed who);
    event LeadRenounced(address indexed caller, address indexed who);

    function setUp(ILead lead_) internal {
        lead = lead_;
    }

    function test_deployment() public {
        // List of leader addresses is empty.
        address[] memory leader = lead.leader();
        assertEq(leader.length, 0);
    }

    function test_hail() public {
        vm.expectEmit(true, true, true, true);
        emit LeadGranted(address(this), address(0xbeef));
        lead.hail(address(0xbeef));

        // Hailed address is leader.
        assertTrue(lead.leader(address(0xbeef)));

        // Hailed address is included in leader list.
        address[] memory leader = lead.leader();
        assertEq(leader.length, 1);
        assertEq(leader[0], address(0xbeef));
    }

    function test_fear() public {
        lead.hail(address(0xbeef));

        vm.expectEmit(true, true, true, true);
        emit LeadRenounced(address(this), address(0xbeef));
        lead.fear(address(0xbeef));

        // Feared address is not leader.
        assertFalse(lead.leader(address(0xbeef)));

        // Feared address is not included in leader list.
        address[] memory leader = lead.leader();
        assertEq(leader.length, 0);
    }

    function test_hail_isAuthProtected() public {
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        lead.hail(address(0));
    }

    function test_fear_isAuthProtected() public {
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        lead.fear(address(0));
    }
}

