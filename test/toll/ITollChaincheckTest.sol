// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {StdStyle} from "forge-std/StdStyle.sol";
import {console2} from "forge-std/console2.sol";

import {IChaincheckTest} from "src/chaincheck/IChaincheckTest.sol";

import {IToll} from "src/toll/IToll.sol";

/**
 * @notice IToll's `chaincheck` Integration Test
 *
 * @dev Config Definition:
 *      ```json
 *      {
 *          "IToll": {
 *              "legacy": bool,
 *              "tolled": [
 *                  "0x000000000000000000000000000000000000cafe", ...
 *              ]
 *          }
 *      }
 *      ```
 */
contract ITollChaincheckTest is IChaincheckTest, Test {
    using stdJson for string;

    IToll private toll;
    string private config;

    string[] private _logs;

    modifier notLegacy() {
        if (!config.readBool(".IToll.legacy")) {
            _;
        }
    }

    function setUp(address self, string memory config_)
        external
        override(IChaincheckTest)
        returns (IChaincheckTest)
    {
        toll = IToll(self);
        config = config_;

        return IChaincheckTest(address(this));
    }

    function run()
        external
        override(IChaincheckTest)
        returns (bool, string[] memory)
    {
        // Run set of integration tests.
        run_tolled_containsAllExpectedAddresses();
        run_tolled_onlyExpectedAddressesAreTolled();
        run_tolled_zeroAddressNotTolled();
        run_tolled_ownAddressNotTolled();

        // Fail run if non-zero number of logs.
        return (_logs.length == 0, _logs);
    }

    /// @dev Checks that each address expected to be tolled is actually tolled.
    function run_tolled_containsAllExpectedAddresses() internal {
        address[] memory expected = config.readAddressArray(".IToll.tolled");

        // Check that each expected address is tolled.
        for (uint i; i < expected.length; i++) {
            // Using `bud(address)(uint)` to support legacy instances.
            if (toll.bud(expected[i]) != 1) {
                _logs.push(StdStyle.red("Expected address not tolled"));
            }
        }
    }

    /// @dev Checks that only addresses specified in the config are actually
    ///      tolled.
    /// @dev Only non-legacy versions supported.

    function run_tolled_onlyExpectedAddressesAreTolled() internal notLegacy {
        address[] memory expected = config.readAddressArray(".IToll.tolled");
        address[] memory actual = toll.tolled();

        for (uint i; i < actual.length; i++) {
            for (uint j; j < expected.length; j++) {
                if (actual[i] == expected[j]) {
                    break; // Found address. Continue with outer loop.
                }

                // Log if unknown address tolled.
                if (j == expected.length - 1) {
                    _logs.push(StdStyle.red("Unknown address tolled"));
                }
            }
        }
    }

    /// @dev Checks that the zero address is not tolled.
    function run_tolled_zeroAddressNotTolled() internal {
        // Using `bud(address)(uint)` to support legacy instances.
        if (toll.bud(address(0)) != 0) {
            _logs.push(StdStyle.red("Zero address is tolled"));
        }
    }

    /// @dev Checks that own address is not tolled.
    function run_tolled_ownAddressNotTolled() internal {
        // Using `bud(address)(uint)` to support legacy instances.
        if (toll.bud(address(toll)) != 0) {
            _logs.push(StdStyle.red("Own address is tolled"));
        }
    }
}
