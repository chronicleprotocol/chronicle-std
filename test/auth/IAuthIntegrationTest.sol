// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {console2} from "forge-std/console2.sol";
import {StdStyle} from "forge-std/StdStyle.sol";

import {IAuth} from "src/auth/IAuth.sol";

/**
 * @notice Provides IAuth Integration Tests.
 *
 * @dev Config Definition:
 *      ```json
 *      {
 *          "legacy": bool,
 *          "authed": [
 *              "0x000000000000000000000000000000000000cafe", ...
 *          ]
 *      }
 *      ```
 */
contract IAuthIntegrationTest is Test {
    using stdJson for string;

    IAuth auth;
    string config;

    modifier notLegacy() {
        if (!config.readBool(".legacy")) {
            _;
        }
    }

    constructor(address instance, string memory config_) {
        auth = IAuth(instance);
        config = config_;
    }

    function run() external {
        // Run set of integration tests.
        run_authed_containsAllExpectedAddresses();
        run_authed_onlyExpectedAddressesAreAuthed();
        run_authed_zeroAddressNotAuthed();
        run_authed_ownAddressNotAuthed();
    }

    /// @dev Checks that each address expected to be auth'ed is actually
    ///      auth'ed.
    function run_authed_containsAllExpectedAddresses() internal {
        address[] memory expected = config.readAddressArray(".authed");

        // Check that each expected address is auth'ed.
        for (uint i; i < expected.length; i++) {
            // Using `wards(address)(uint)` to support legacy instances.
            if (auth.wards(expected[i]) != 1) {
                console2.log(
                    StdStyle.red("Expected address not auth'ed"), expected[i]
                );
                assertTrue(false);
            }
        }
    }

    /// @dev Checks that only addresses specified in the config are actually
    ///      auth'ed.
    /// @dev Only non-legacy versions supported!
    function run_authed_onlyExpectedAddressesAreAuthed() internal notLegacy {
        address[] memory expected = config.readAddressArray(".authed");
        address[] memory actual = auth.authed();

        for (uint i; i < actual.length; i++) {
            for (uint j; j < expected.length; j++) {
                if (actual[i] == expected[i]) {
                    break; // Found address. Continue with outer loop.
                }

                // Fail if unknown address auth'ed.
                if (j == expected.length - 1) {
                    console2.log(
                        StdStyle.red("Unknown address auth'ed"), actual[i]
                    );
                    assertTrue(false);
                }
            }
        }
    }

    /// @dev Checks that the zero address is not auth'ed.
    function run_authed_zeroAddressNotAuthed() internal {
        // Using `wards(address)(uint)` to support legacy instances.
        if (auth.wards(address(0)) != 0) {
            console2.log(StdStyle.red("Zero address is auth'ed"));
            assertTrue(false);
        }
    }

    /// @dev Checks that own address is not auth'ed.
    function run_authed_ownAddressNotAuthed() internal {
        // Using `wards(address)(uint)` to support legacy instances.
        if (auth.wards(address(auth)) != 0) {
            console2.log(StdStyle.red("Own address is auth'ed"));
            assertTrue(false);
        }
    }
}
