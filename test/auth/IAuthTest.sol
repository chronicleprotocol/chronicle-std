// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";

import {IAuth} from "src/auth/IAuth.sol";

/**
 * @notice Provides IAuth Unit Tests.
 */
abstract contract IAuthTest is Test {
    IAuth auth;

    event AuthGranted(address indexed by, address indexed to);
    event AuthRenounced(address indexed by, address indexed to);

    function setUp(IAuth auth_) internal {
        auth = auth_;
    }

    function test_deployment() public {
        // Address given as constructor argument is auth'ed.
        assertTrue(auth.authed(address(this)));

        // Address given as constructor is included in authed list.
        address[] memory authed = auth.authed();
        assertEq(authed.length, 1);
        assertEq(authed[0], address(this));
    }

    /// @dev Tests API backwards compatibility.
    function test_deprecated_wards() public {
        assertEq(auth.wards(address(this)), 1);
    }

    function test_rely() public {
        vm.expectEmit(true, true, true, true);
        emit AuthGranted(address(this), address(0xbeef));
        auth.rely(address(0xbeef));

        // Relied address is auth'ed.
        assertTrue(auth.authed(address(0xbeef)));

        // Relied address is included in authed list.
        address[] memory authed = auth.authed();
        assertEq(authed.length, 2);
        assertEq(authed[1], address(0xbeef));
    }

    function test_deny() public {
        auth.rely(address(0xbeef));

        vm.expectEmit(true, true, true, true);
        emit AuthRenounced(address(this), address(0xbeef));
        auth.deny(address(0xbeef));

        // Denied address is not auth'ed.
        assertFalse(auth.authed(address(0xbeef)));

        // Denied address is not included in authed list.
        address[] memory authed = auth.authed();
        assertEq(authed.length, 1);
        assertEq(authed[0], address(this));
    }

    function test_rely_isAuthProtected() public {
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        auth.rely(address(0));
    }

    function test_deny_isAuthProtected() public {
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        auth.deny(address(0));
    }
}
