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
 *      ```json
 *      {
 *          "IToll": {
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
        override(Chaincheck)
        returns (Chaincheck)
    {
        toll = IToll(self);
        config = config_;

        return Chaincheck(address(this));
    }

    function run()
        external
        override(Chaincheck)
        returns (bool, string[] memory)
    {
        check_tolled_containsAllExpectedAddresses();
        check_tolled_onlyExpectedAddressesAreTolled();
        check_tolled_zeroAddressNotTolled();
        check_tolled_ownAddressNotTolled();

        // Fail run if non-zero number of logs.
        return (_logs.length == 0, _logs);
    }

    /// @dev Checks that each address expected to be tolled is actually tolled.
    function check_tolled_containsAllExpectedAddresses() internal {
        address[] memory expected = config.readAddressArray(".IToll.tolled");

        // Check that each expected address is tolled.
        for (uint i; i < expected.length; i++) {
            // Using `bud(address)(uint)` to support legacy instances.
            if (toll.bud(expected[i]) != 1) {
                _logs.push(
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
        address[] memory actual = toll.tolled();

        for (uint i; i < actual.length; i++) {
            for (uint j; j < expected.length; j++) {
                if (actual[i] == expected[j]) {
                    break; // Found address. Continue with outer loop.
                }

                // Log if unknown address tolled.
                if (j == expected.length - 1) {
                    _logs.push(
                        string.concat(
                            StdStyle.red("Unknown address tolled: "),
                            vm.toString(actual[i])
                        )
                    );
                }
            }
        }
    }

    /// @dev Checks that the zero address is not tolled.
    function check_tolled_zeroAddressNotTolled() internal {
        // Using `bud(address)(uint)` to support legacy instances.
        if (toll.bud(address(0)) != 0) {
            _logs.push(StdStyle.red("Zero address tolled"));
        }
    }

    /// @dev Checks that own address is not tolled.
    function check_tolled_ownAddressNotTolled() internal {
        // Using `bud(address)(uint)` to support legacy instances.
        if (toll.bud(address(toll)) != 0) {
            _logs.push(StdStyle.red("Own address tolled"));
        }
    }
}
