// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {Auth} from "src/auth/Auth.sol";

import {IBuddy} from "./IBuddy.sol";

/**
 * @title Buddy Module
 *
 * @notice "Toll paid, we kiss to make buddy - but dissension looms, maybe diss a fren?"
 *
 * @dev The `Buddy` contract module provides a basic access control mechanism,
 *      where a set of addresses are granted access to protected functions.
 *      These addresses are said to be _buddies_.
 *
 *      The contract inherits the `Auth` module for own access control.
 *
 *      Through the `kiss(address)` and `diss(address)` functions, auth'ed
 *      callers are able to grant/renounce an address to/from being a buddy.
 */
abstract contract Buddy is IBuddy, Auth {
    /// @dev Mapping storing whether address is buddy.
    /// @custom:invariant Image of mapping is {0, 1}.
    ///                     ∀x ∊ Address: _buddies[x] ∊ {0, 1}
    /// @custom:invariant Only functions `kiss` and `diss` may mutate the mapping's state.
    ///                     ∀x ∊ Address: preTx(_buddies[x]) != postTx(_buddies[x])
    ///                                     → (msg.sig == "kiss" ∨ msg.sig == "diss")
    /// @custom:invariant Mapping's state may only be mutated by authenticated caller.
    ///                     ∀x ∊ Address: preTx(_buddies[x]) != postTx(_buddies[x])
    ///                                     → authed(msg.sender)
    mapping(address => uint) private _buddies;

    /// @dev List of addresses possibly being a bud.
    /// @dev May contain duplicates.
    /// @dev May contain addresses not being buddy anymore.
    /// @custom:invariant Every address being a bud once is element of the list.
    ///                     ∀x ∊ Address: _buddies[x] → x ∊ _buddiesTouched
    address[] private _buddiesTouched;

    /// @dev Ensures caller is buddy.
    modifier toll() {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute slot of _buddies[msg.sender].
            mstore(0x00, caller())
            mstore(0x20, _buddies.slot)
            let slot := keccak256(0x00, 0x40)

            // Revert if caller not buddy.
            let isBuddy := sload(slot)
            if iszero(isBuddy) {
                // Store selector of `NotBuddy(address)`.
                mstore(0x00, 0x862e834f)
                // Store msg.sender.
                mstore(0x20, caller())
                // Revert with (offset, size).
                revert(0x1c, 0x24)
            }
        }
        _;
    }

    /// @inheritdoc IBuddy
    function kiss(address who) external override(IBuddy) auth {
        if (_buddies[who] == 1) return;

        _buddies[who] = 1;
        _buddiesTouched.push(who);
        emit BuddyKissed(msg.sender, who);
    }

    /// @inheritdoc IBuddy
    function diss(address who) external override(IBuddy) auth {
        if (_buddies[who] == 0) return;

        _buddies[who] = 0;
        emit BuddyDissed(msg.sender, who);
    }

    /// @inheritdoc IBuddy
    function buddies(address who) public view override(IBuddy) returns (bool) {
        return _buddies[who] == 1;
    }

    /// @inheritdoc IBuddy
    /// @custom:invariant Only contains buddies.
    ///                     ∀x ∊ buddies(): _buddies[x]
    /// @custom:invariant Contains all buddies.
    ///                     ∀x ∊ Address: _buddies[x] == 1 → x ∊ buddies()
    function buddies()
        public
        view
        override(IBuddy)
        returns (address[] memory)
    {
        // Initiate array with upper limit length.
        address[] memory buddiesList = new address[](_buddiesTouched.length);

        // Iterate through all possible buddies.
        uint ctr;
        for (uint i; i < buddiesList.length; i++) {
            // Add address only if still buddy.
            if (_buddies[_buddiesTouched[i]] == 1) {
                buddiesList[ctr++] = _buddiesTouched[i];
            }
        }

        // Set length of array to number of buddies actually included.
        /// @solidity memory-safe-assembly
        assembly {
            mstore(buddiesList, ctr)
        }

        return buddiesList;
    }

    /// @inheritdoc IBuddy
    function bud(address who) public view override(IBuddy) returns (uint) {
        return _buddies[who];
    }
}
