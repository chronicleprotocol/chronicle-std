// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";

/**
 * @title IChaincheckTest
 *
 * @custom:example Running a ChaincheckTest.
 * ```solidity
 * import {ChainlogChaincheckTest} from "...";
 * function test() public {
 *     string memory config = vm.readFile("path/to/config.json");
 *     address instance = config.readString(".address");
 *     bool ok;
 *     string[] memory logs;
 *     (ok, logs) = ChaincheckTest(new ChainlogChaincheckTest())
 *                     .setUp(instance, config)
 *                     .run();
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
