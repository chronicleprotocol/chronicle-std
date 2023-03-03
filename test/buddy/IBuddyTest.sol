// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";

import {IBuddy} from "src/buddy/IBuddy.sol";
import {IAuth} from "src/auth/IAuth.sol";

/**
 * @notice Provides IBuddy Unit Tests.
 */
abstract contract IBuddyTest is Test {
    IBuddy buddy;

    event BuddyKissed(address indexed caller, address indexed who);
    event BuddyDissed(address indexed caller, address indexed who);

    function setUp(IBuddy buddy_) internal {
        buddy = buddy_;
    }

    function test_deployment() public {
        // Deployer is auth'ed.
        assertTrue(IAuth(address(buddy)).authed(address(this)));

        // List of buddies is empty.
        address[] memory buddies = buddy.buddies();
        assertEq(buddies.length, 0);
    }

    /// @dev Tests API backwards compatibility.
    function test_deprecated_bud() public {
        buddy.kiss(address(0xcafe));
        assertEq(buddy.bud(address(0xcafe)), 1);
    }

    function test_kiss() public {
        vm.expectEmit(true, true, true, true);
        emit BuddyKissed(address(this), address(0xbeef));
        buddy.kiss(address(0xbeef));

        // Kissed address is buddy.
        assertTrue(buddy.buddies(address(0xbeef)));

        // Kissed address is included in buddies list.
        address[] memory buddies = buddy.buddies();
        assertEq(buddies.length, 1);
        assertEq(buddies[0], address(0xbeef));
    }

    function test_diss() public {
        buddy.kiss(address(0xbeef));

        vm.expectEmit(true, true, true, true);
        emit BuddyDissed(address(this), address(0xbeef));
        buddy.diss(address(0xbeef));

        // Dissed address is not buddy.
        assertFalse(buddy.buddies(address(0xbeef)));

        // Dissed address is not included in buddies list.
        address[] memory buddies = buddy.buddies();
        assertEq(buddies.length, 0);
    }

    function test_kiss_isAuthProtected() public {
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        buddy.kiss(address(0));
    }

    function test_diss_isAuthProtected() public {
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        buddy.diss(address(0));
    }
}
