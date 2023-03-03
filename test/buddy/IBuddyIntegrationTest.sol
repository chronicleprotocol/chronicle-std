// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {console2} from "forge-std/console2.sol";
import {StdStyle} from "forge-std/StdStyle.sol";

import {IBuddy} from "src/buddy/IBuddy.sol";

/**
 * @notice Provides IBuddy Integration Tests.
 *
 * @dev Config Definition:
 *      ```json
 *      {
 *          "IBuddy": {
 *              "legacy": bool,
 *              "buddies": [
 *                  "0x000000000000000000000000000000000000cafe", ...
 *              ]
 *          }
 *      }
 *      ```
 */
contract IBuddyIntegrationTest is Test {
    using stdJson for string;

    IBuddy buddy;
    string config;

    modifier notLegacy() {
        if (!config.readBool(".IBuddy.legacy")) {
            _;
        }
    }

    constructor(address instance, string memory config_) {
        buddy = IBuddy(instance);
        config = config_;
    }

    function run() external {
        // Run set of integration tests.
        run_buddies_containsAllExpectedAddresses();
        run_buddies_onlyExpectedAddressesAreAuthed();
        run_buddies_zeroAddressNotBuddy();
        run_buddies_ownAddressNotBuddy();
    }

    /// @dev Checks that each address expected to be a buddy is actually
    ///      a buddy.

    function run_buddies_containsAllExpectedAddresses() internal {
        address[] memory expected = config.readAddressArray(".IBuddy.buddies");

        // Check that each expected address is buddy.
        for (uint i; i < expected.length; i++) {
            // Using `bud(address)(uint)` to support legacy instances.
            if (buddy.bud(expected[i]) != 1) {
                console2.log(
                    StdStyle.red("Expected address not buddy"), expected[i]
                );
                assertTrue(false);
            }
        }
    }

    /// @dev Checks that only addresses specified in the config are actually
    ///      buddies.
    /// @dev Only non-legacy versions supported!

    function run_buddies_onlyExpectedAddressesAreAuthed() internal notLegacy {
        address[] memory expected = config.readAddressArray(".IBuddy.buddies");
        address[] memory actual = buddy.buddies();

        for (uint i; i < actual.length; i++) {
            for (uint j; j < expected.length; j++) {
                if (actual[i] == expected[j]) {
                    break; // Found address. Continue with outer loop.
                }

                // Fail if unknown address buddy.
                if (j == expected.length - 1) {
                    console2.log(
                        StdStyle.red("Unknown address buddy"), actual[i]
                    );
                    assertTrue(false);
                }
            }
        }
    }

    /// @dev Checks that the zero address is not buddy.
    function run_buddies_zeroAddressNotBuddy() internal {
        // Using `bud(address)(uint)` to support legacy instances.
        if (buddy.bud(address(0)) != 0) {
            console2.log(StdStyle.red("Zero address is buddy"));
            assertTrue(false);
        }
    }

    /// @dev Checks that own address is not buddy.
    function run_buddies_ownAddressNotBuddy() internal {
        // Using `bud(address)(uint)` to support legacy instances.
        if (buddy.bud(address(buddy)) != 0) {
            console2.log(StdStyle.red("Own address is buddy"));
            assertTrue(false);
        }
    }
}
