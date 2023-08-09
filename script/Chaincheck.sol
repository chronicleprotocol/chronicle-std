// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @title Chaincheck
 *
 * @notice Verifiable onchain configurations
 *
 * @dev The `Chaincheck` module specifies how contracts must implement their
 *      integration tests in order to be executable via `chaincheck`.
 *
 * @custom:example Running a Chaincheck contract:
 *
 *      ```solidity
 *      import {ChainlogChaincheck} from "...";
 *
 *      function test() public {
 *          // Instantiate fork environment.
 *          vm.createSelectFork("RPC_URL");
 *
 *          // Read config file.
 *          string memory config = vm.readFile("path/to/config.json");
 *
 *          // Read address of contract.
 *          address instance = config.readString(".address");
 *
 *          // Run chaincheck integration test.
 *          bool ok;
 *          string[] memory logs;
 *          (ok, logs) = Chaincheck(new ChainlogChaincheck())
 *                          .setUp(instance, config)
 *                          .run();
 *
 *          // If run failed, print logs.
 *          if (!ok) print(logs);
 *      }
 *      ```
 */
abstract contract Chaincheck {
    function setUp(address self, string memory config)
        external
        virtual
        returns (Chaincheck);

    function run() external virtual returns (bool, string[] memory);
}
