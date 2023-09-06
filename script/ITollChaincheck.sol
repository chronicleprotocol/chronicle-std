// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Vm} from "forge-std/Vm.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {StdStyle} from "forge-std/StdStyle.sol";
import {console2} from "forge-std/console2.sol";

import {Chaincheck} from "./Chaincheck.sol";

import {IToll} from "src/toll/IToll.sol";

/**
 * @notice IToll's `chaincheck` Integration Test
 *
 * @dev Config Definition:
 *
 *      ```json
 *      {
 *          "IToll": {
 *              "disabled": bool,
 *              "legacy": bool,
 *              "tolled": [
 *                  "<Ethereum address>",
 *                  ...
 *              ]
 *          }
 *      }
 *      ```
 */
contract ITollChaincheck is Chaincheck {
    using stdJson for string;

    Vm internal constant vm =
        Vm(address(uint160(uint(keccak256("hevm cheat code")))));

    IToll self;
    string config;

    string[] logs;

    modifier notLegacy() {
        if (!config.readBool(".IToll.legacy")) {
            _;
        }
    }

    function setUp(address self_, string memory config_)
        external
        override(Chaincheck)
        returns (Chaincheck)
    {
        self = IToll(self_);
        config = config_;

        return Chaincheck(address(this));
    }

    function run()
        external
        override(Chaincheck)
        returns (bool, string[] memory)
    {
        // Don't run if disabled.
        if (config.readBool(".IToll.disabled")) {
            return (logs.length == 0, logs);
        }

        check_tolled_containsAllExpectedAddresses();
        check_tolled_onlyExpectedAddressesAreTolled();
        check_tolled_zeroAddressNotTolled();
        check_tolled_ownAddressNotTolled();

        // Fail run if non-zero number of logs.
        return (logs.length == 0, logs);
    }

    /// @dev Checks that each address expected to be tolled is actually tolled.
    function check_tolled_containsAllExpectedAddresses() internal {
        address[] memory expected = config.readAddressArray(".IToll.tolled");

        // Check that each expected address is tolled.
        for (uint i; i < expected.length; i++) {
            // Using `bud(address)(uint)` to support legacy instances.
            if (self.bud(expected[i]) != 1) {
                logs.push(
                    string.concat(
                        StdStyle.red("Expected address not tolled: "),
                        vm.toString(expected[i])
                    )
                );
            }
        }
    }

    /// @dev Checks that only addresses specified in the config are actually
    ///      tolled.
    /// @dev Only non-legacy versions supported.
    function check_tolled_onlyExpectedAddressesAreTolled() internal notLegacy {
        address[] memory expected = config.readAddressArray(".IToll.tolled");
        address[] memory actual = self.tolled();

        for (uint i; i < actual.length; i++) {
            bool found = false;

            for (uint j; j < expected.length; j++) {
                if (actual[i] == expected[j]) {
                    found = true;
                    break; // Found address. Continue with outer loop.
                }
            }

            // Log if unknown address tolled.
            if (!found) {
                logs.push(
                    string.concat(
                        StdStyle.red("Unknown address tolled: "),
                        vm.toString(actual[i])
                    )
                );
            }
        }
    }

    /// @dev Checks that the zero address is not tolled.
    function check_tolled_zeroAddressNotTolled() internal {
        // Using `bud(address)(uint)` to support legacy instances.
        if (self.bud(address(0)) != 0) {
            logs.push(StdStyle.red("Zero address tolled"));
        }
    }

    /// @dev Checks that own address is not tolled.
    function check_tolled_ownAddressNotTolled() internal {
        // Using `bud(address)(uint)` to support legacy instances.
        if (self.bud(address(self)) != 0) {
            logs.push(StdStyle.red("Own address tolled"));
        }
    }
}
