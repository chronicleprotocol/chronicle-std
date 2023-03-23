// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";

/**
 * @title ChaincheckTest
 *
 * @notice Verifiable onchain configurations
 *
 * @dev The `ChaincheckTest` module specifies how contracts must implement
 *      their integration tests in order to be executable via `chaincheck`.
 *
 * @custom:example Running a ChaincheckTest contract.
 * ```solidity
 * import {ChainlogChaincheckTest} from "...";
 * function test() public {
 *     // Instantiate fork environment.
 *     vm.createSelectFork("RPC_URL");
 *     // Read config file.
 *     string memory config = vm.readFile("path/to/config.json");
 *     // Read address of contract.
 *     address instance = config.readString(".address");
 *     // Run chaincheck integration test.
 *     bool ok;
 *     string[] memory logs;
 *     (ok, logs) = ChaincheckTest(new ChainlogChaincheckTest())
 *                     .setUp(instance, config)
 *                     .run();
 *     // If run failed, print logs.
 *     if (!ok) print(logs);
 * }
 * ```
 */
abstract contract ChaincheckTest is Test {
    function setUp(address self, string memory config)
        external
        virtual
        returns (ChaincheckTest);

    function run() external virtual returns (bool, string[] memory);
}
