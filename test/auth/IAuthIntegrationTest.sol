// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";

import {IAuth} from "src/auth/IAuth.sol";

// TODO: Not yet tested. Get deployed instance and config.

/**
 * @notice Provides IAuth Integration Tests.
 *
 * @dev These tests are expected to be executed in downstream projects.
 *
 *      To setup integration tests for deployed IAuth instances:
 *
 *      ```solidity
 *      import {IAuthIntegrationTest} from "lib/auth/test/IAuthIntegrationTest.sol"
 *
 *      contract AuthIntegrationTest is IAuthIntegrationTest {
 *          // TODO: Create Configuration struct.
 *          IAuthIntegrationTest.Configuration config = ...:
 *
 *          function setUp() public {
 *              setUp(config);
 *          }
 *      }
 *      ```
 */
abstract contract IAuthIntegrationTest is Test {
    struct Configuration {
        /// @dev The auth instance to test.
        IAuth auth;
        /// @dev The chain instance from which to fork.
        Chain chain;
        /// @dev Whether auth is a legay instance, i.e. does not support
        ///      `authed(address)(bool)` and `authed()(address[]) functions.
        bool legacy;
        /// @dev The list of expected auth'ed addresses.
        address[] authed;
    }

    Configuration private config;

    function setUp(Configuration memory config_) internal {
        config = config_;

        // Initiate fork.
        vm.createSelectFork(config.chain.rpcUrl);
    }

    function test_integration_authed() public {
        if (config.legacy) return;

        // Every address in config.authed is auth'ed.
        for (uint i; i < config.authed.length; i++) {
            assertTrue(config.auth.authed(config.authed[i]));
        }

        // Every address returned by auth.authed() is in config.authed.
        address[] memory authed = config.auth.authed();
        for (uint i; i < authed.length; i++) {
            for (uint j; j < config.authed.length; j++) {
                // Break inner loop if address found.
                if (authed[i] == config.authed[j]) {
                    break;
                }

                // Fail if address not found.
                if (j == config.authed.length - 1) {
                    assertTrue(false);
                }
            }
        }
    }

    /// @dev Used for legacy Auth instances only providing the
    ///      `ward(address)(uint)` function.
    function test_integration_legacy_authed() public {
        // Every address in config.authed is auth'ed.
        for (uint i; i < config.authed.length; i++) {
            assertEq(config.auth.wards(config.authed[i]), 1);
        }
    }
}
