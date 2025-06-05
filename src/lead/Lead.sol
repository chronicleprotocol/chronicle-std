// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {ILead} from "./ILead.sol";

/**
 * @title Lead Module
 *
 * @dev The `Lead` contract module provides a basic access control mechanism,
 *      where a set of addresses are granted access to protected functions.
 *      These addresses are said the be _leader_.
 *
 *      Initially, no address is leader. Through the `hail(address)` and
 *      `fear(address)` functions, auth'ed callers are able to make or remove
 *      addresses leaders. Authentication for these functions is defined via the
 *      downstream implemented `lead_auth()` function.
 *
 *      This module is used through inheritance. It will make available the
 *      modifier `lead`, which can be applied to functions to restrict their
 *      use to only leader callers.
 */
abstract contract Lead is ILead {
    /// @dev Mapping storing whether address is leader.
    /// @custom:invariant Image of mapping is {0, 1}.
    ///                     ∀x ∊ Address: _chefs[x] ∊ {0, 1}
    /// @custom:invariant Only functions `hail` and `fear` may mutate the mapping's state.
    ///                     ∀x ∊ Address: preTx(_chefs[x]) != postTx(_chefs[x])
    ///                                     → (msg.sig == "hail" ∨ msg.sig == "fear")
    /// @custom:invariant Mapping's state may only be mutated by authenticated caller.
    ///                     ∀x ∊ Address: preTx(_chefs[x]) != postTx(_fuds[x])
    ///                                     → load_auth()
    mapping(address => uint) private _chefs;

    /// @dev List of addresses possibly being leader.
    /// @dev May contain duplicates.
    /// @dev May contain addresses not being leader anymore.
    /// @custom:invariant Every address being leader once is element of the list.
    ///                     ∀x ∊ Address: leader(x) → x ∊ _chefsTouched
    address[] private _chefsTouched;

    /// @dev Ensures caller is leader.
    modifier lead() {
        assembly ("memory-safe") {
            // Compute slot of _chefs[msg.sender].
            mstore(0x00, caller())
            mstore(0x20, _chefs.slot)
            let slot := keccak256(0x00, 0x40)

            // Revert if caller not tolled.
            let isLeader := sload(slot)
            if iszero(isLeader) {
                // Store selector of `NotLeader(address)`.
                mstore(0x00, 0x5c8e2a85)
                // Store msg.sender.
                mstore(0x20, caller())
                // Revert with (offset, size).
                revert(0x1c, 0x24)
            }
        }
        _;
    }

    /// @dev Reverts if caller not allowed to access protected function.
    /// @dev Must be implemented in downstream contract.
    function lead_auth() internal virtual;

    /// @inheritdoc ILead
    function hail(address who) external {
        lead_auth();

        if (_chefs[who] == 1) return;

        _chefs[who] = 1;
        _chefsTouched.push(who);
        emit LeadGranted(msg.sender, who);
    }

    /// @inheritdoc ILead
    function fear(address who) external {
        lead_auth();

        if (_chefs[who] == 0) return;

        _chefs[who] = 0;
        emit LeadRenounced(msg.sender, who);
    }

    /// @inheritdoc ILead
    function leader(address who) public view returns (bool) {
        return _chefs[who] == 1;
    }

    /// @inheritdoc ILead
    /// @custom:invariant Only contains leader addresses.
    ///                     ∀x ∊ leader(): _chefs[x]
    /// @custom:invariant Contains all leader addresses.
    ///                     ∀x ∊ Address: _chefs[x] == 1 → x ∊ leader()
    function leader() public view returns (address[] memory) {
        // Initiate array with upper limit length.
        address[] memory chefsList = new address[](_chefsTouched.length);

        // Iterate through all possible leader addresses.
        uint ctr;
        for (uint i; i < chefsList.length; i++) {
            // Add address only if still tolled.
            if (_chefs[_chefsTouched[i]] == 1) {
                chefsList[ctr++] = _chefsTouched[i];
            }
        }

        // Set length of array to number of tolled addresses actually included.
        assembly ("memory-safe") {
            mstore(chefsList, ctr)
        }

        return chefsList;
    }
}

