// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {stdJson} from "forge-std/StdJson.sol";
import {StdStyle} from "forge-std/StdStyle.sol";

import {ChaincheckTest} from "src/chaincheck/ChaincheckTest.sol";

import {IAuth} from "./IAuth.sol";

/**
 * @notice IAuth's `chaincheck` Integration Test
 *
 * @dev Config Definition:
 * ```json
 * {
 *     "IAuth": {
 *         "legacy": bool,
 *         "authed": [
 *             "0x000000000000000000000000000000000000cafe",
 *             ...
 *         ]
 *     }
 * }
 * ```
 */
contract IAuthChaincheckTest is ChaincheckTest {
    using stdJson for string;

    IAuth private auth;
    string private config;

    string[] private _logs;

    modifier notLegacy() {
        if (!config.readBool(".IAuth.legacy")) {
            _;
        }
    }

    function setUp(address self, string memory config_)
        external
        override(ChaincheckTest)
        returns (ChaincheckTest)
    {
        auth = IAuth(self);
        config = config_;

        return ChaincheckTest(address(this));
    }

    function run()
        external
        override(ChaincheckTest)
        returns (bool, string[] memory)
    {
        check_authed_containsAllExpectedAddresses();
        check_authed_onlyExpectedAddressesAreAuthed();
        check_authed_zeroAddressNotAuthed();
        check_authed_ownAddressNotAuthed();

        // Fail run if non-zero number of logs.
        return (_logs.length == 0, _logs);
    }

    /// @dev Checks that each address expected to be auth'ed is actually
    ///      auth'ed.
    function check_authed_containsAllExpectedAddresses() internal {
        address[] memory expected = config.readAddressArray(".IAuth.authed");

        // Check that each expected address is auth'ed.
        for (uint i; i < expected.length; i++) {
            // Using `wards(address)(uint)` to support legacy instances.
            if (auth.wards(expected[i]) != 1) {
                _logs.push(
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
        address[] memory actual = auth.authed();

        for (uint i; i < actual.length; i++) {
            for (uint j; j < expected.length; j++) {
                if (actual[i] == expected[j]) {
                    break; // Found address. Continue with outer loop.
                }

                // Log if unknown address auth'ed.
                if (j == expected.length - 1) {
                    _logs.push(
                        string.concat(
                            StdStyle.red("Unknown address auth'ed: "), vm.toString(actual[i])
                        )
                    );
                }
            }
        }
    }

    /// @dev Checks that the zero address is not auth'ed.
    function check_authed_zeroAddressNotAuthed() internal {
        // Using `wards(address)(uint)` to support legacy instances.
        if (auth.wards(address(0)) != 0) {
            _logs.push(StdStyle.red("Zero address auth'ed"));
        }
    }

    /// @dev Checks that own address is not auth'ed.
    function check_authed_ownAddressNotAuthed() internal {
        // Using `wards(address)(uint)` to support legacy instances.
        if (auth.wards(address(auth)) != 0) {
            _logs.push(StdStyle.red("Own address auth'ed"));
        }
    }
}
