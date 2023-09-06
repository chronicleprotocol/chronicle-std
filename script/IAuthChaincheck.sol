// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Vm} from "forge-std/Vm.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {StdStyle} from "forge-std/StdStyle.sol";

import {Chaincheck} from "./Chaincheck.sol";

import {IAuth} from "src/auth/IAuth.sol";

/**
 * @notice IAuth's `chaincheck` Integration Test
 *
 * @dev Config Definition:
 *
 *      ```json
 *      {
 *          "IAuth": {
 *              "disabled": bool,
 *              "legacy": bool,
 *              "authed": [
 *                  "<Ethereum address>",
 *                  ...
 *              ]
 *          }
 *      }
 *      ```
 */
contract IAuthChaincheck is Chaincheck {
    using stdJson for string;

    Vm internal constant vm =
        Vm(address(uint160(uint(keccak256("hevm cheat code")))));

    IAuth self;
    string config;

    string[] logs;

    modifier notLegacy() {
        if (!config.readBool(".IAuth.legacy")) {
            _;
        }
    }

    function setUp(address self_, string memory config_)
        external
        override(Chaincheck)
        returns (Chaincheck)
    {
        self = IAuth(self_);
        config = config_;

        return Chaincheck(address(this));
    }

    function run()
        external
        override(Chaincheck)
        returns (bool, string[] memory)
    {
        // Don't run if disabled.
        if (config.readBool(".IAuth.disabled")) {
            return (logs.length == 0, logs);
        }

        check_authed_containsAllExpectedAddresses();
        check_authed_onlyExpectedAddressesAreAuthed();
        check_authed_zeroAddressNotAuthed();
        check_authed_ownAddressNotAuthed();

        // Fail run if non-zero number of logs.
        return (logs.length == 0, logs);
    }

    /// @dev Checks that each address expected to be auth'ed is actually
    ///      auth'ed.
    function check_authed_containsAllExpectedAddresses() internal {
        address[] memory expected = config.readAddressArray(".IAuth.authed");

        // Check that each expected address is auth'ed.
        for (uint i; i < expected.length; i++) {
            // Using `wards(address)(uint)` to support legacy instances.
            if (self.wards(expected[i]) != 1) {
                logs.push(
                    string.concat(
                        StdStyle.red("Expected address not auth'ed: "),
                        vm.toString(expected[i])
                    )
                );
            }
        }
    }

    /// @dev Checks that only addresses specified in the config are actually
    ///      auth'ed.
    /// @dev Only non-legacy versions supported.
    function check_authed_onlyExpectedAddressesAreAuthed() internal notLegacy {
        address[] memory expected = config.readAddressArray(".IAuth.authed");
        address[] memory actual = self.authed();

        for (uint i; i < actual.length; i++) {
            bool found = false;

            for (uint j; j < expected.length; j++) {
                if (actual[i] == expected[j]) {
                    found = true;
                    break; // Found address. Continue with outer loop.
                }
            }

            if (!found) {
                // Log if unknown address auth'ed.
                logs.push(
                    string.concat(
                        StdStyle.red("Unknown address auth'ed: "),
                        vm.toString(actual[i])
                    )
                );
            }
        }
    }

    /// @dev Checks that the zero address is not auth'ed.
    function check_authed_zeroAddressNotAuthed() internal {
        // Using `wards(address)(uint)` to support legacy instances.
        if (self.wards(address(0)) != 0) {
            logs.push(StdStyle.red("Zero address auth'ed"));
        }
    }

    /// @dev Checks that own address is not auth'ed.
    function check_authed_ownAddressNotAuthed() internal {
        // Using `wards(address)(uint)` to support legacy instances.
        if (self.wards(address(self)) != 0) {
            logs.push(StdStyle.red("Own address auth'ed"));
        }
    }
}
