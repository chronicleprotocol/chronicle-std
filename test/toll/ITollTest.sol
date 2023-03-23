// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";

import {IToll} from "src/toll/IToll.sol";
import {IAuth} from "src/auth/IAuth.sol";

/**
 * @notice Provides IToll Unit Tests.
 */
abstract contract ITollTest is Test {
    IToll toll;

    event TollGranted(address indexed caller, address indexed who);
    event TollRenounced(address indexed caller, address indexed who);

    function setUp(IToll toll_) internal {
        toll = toll_;
    }

    function test_deployment() public {
        // List of tolled addresses is empty.
        address[] memory tolled = toll.tolled();
        assertEq(tolled.length, 0);
    }

    /// @dev Tests API backwards compatibility.
    function test_deprecated_bud() public {
        assertEq(toll.bud(address(0xcafe)), 0);
        toll.kiss(address(0xcafe));
        assertEq(toll.bud(address(0xcafe)), 1);
    }

    function test_kiss() public {
        vm.expectEmit(true, true, true, true);
        emit TollGranted(address(this), address(0xbeef));
        toll.kiss(address(0xbeef));

        // Kissed address is tolled.
        assertTrue(toll.tolled(address(0xbeef)));

        // Kissed address is included in tolled list.
        address[] memory tolled = toll.tolled();
        assertEq(tolled.length, 1);
        assertEq(tolled[0], address(0xbeef));
    }

    function test_diss() public {
        toll.kiss(address(0xbeef));

        vm.expectEmit(true, true, true, true);
        emit TollRenounced(address(this), address(0xbeef));
        toll.diss(address(0xbeef));

        // Dissed address is not tolled.
        assertFalse(toll.tolled(address(0xbeef)));

        // Dissed address is not included in tolled list.
        address[] memory tolled = toll.tolled();
        assertEq(tolled.length, 0);
    }

    function test_kiss_isAuthProtected() public {
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        toll.kiss(address(0));
    }

    function test_diss_isAuthProtected() public {
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        toll.diss(address(0));
    }
}
