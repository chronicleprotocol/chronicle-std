// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

/**
 * @title IChaincheckTest
 *
 * @custom:example Running an IChaincheckTest.
 * ```solidity
 * import {Chainlog_ChaincheckTest} from "...";
 * function test() public {
 *     string memory config = vm.readFile("path/to/config.json");
 *     address instance = config.readString(".address");
 *     bool ok;
 *     string[] memory logs;
 *     (ok, logs) = IChaincheckTest(new Chainlog_ChaincheckTest())
 *                      .setUp(instance, config)
 *                      .run();
 *     if (!ok) print(logs);
 * }
 * ```
 */
interface IChaincheckTest {
    function setUp(address self, string memory config)
        external
        returns (IChaincheckTest);

    function run() external returns (bool, string[] memory);
}
