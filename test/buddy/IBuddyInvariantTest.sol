// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {CommonBase} from "forge-std/Base.sol";

import {IBuddy} from "src/buddy/IBuddy.sol";
import {IAuth} from "src/auth/IAuth.sol";

/**
 * @notice Provides IBuddy Invariant Tests.
 */
abstract contract IBuddyInvariantTest is Test {
    IBuddy buddy;
    Handler handler;

    function setUp(IBuddy buddy_) internal {
        buddy = buddy_;

        handler = new Handler(buddy);
        IAuth(address(buddy)).rely(address(handler));

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = Handler.kiss.selector;
        selectors[1] = Handler.diss.selector;

        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
        targetContract(address(handler));
    }

    function invariant_buddies_onlyContainsBuddies() public {
        address[] memory buddies = buddy.buddies();

        for (uint i; i < buddies.length; i++) {
            assertTrue(buddy.buddies(buddies[i]));
        }
    }

    function invariant_buddies_containsAllBuddies() public {
        address[] memory buddiesTouched = handler.ghost_buddiesTouched();
        address[] memory buddies = buddy.buddies();

        for (uint i; i < buddiesTouched.length; i++) {
            // If touched address is buddy...
            if (buddy.buddies(buddiesTouched[i])) {
                // ...buddies list must contain it.
                for (uint j; j < buddies.length; j++) {
                    // Break inner loop if buddy found.
                    if (buddies[j] == buddiesTouched[i]) {
                        break;
                    }

                    // Fail if buddies list does not contain buddy.
                    if (j == buddies.length - 1) {
                        assertTrue(false);
                    }
                }
            }
        }
    }

    function invariant_bud_imageIsZeroOne() public {
        address[] memory buddiesTouched = handler.ghost_buddiesTouched();

        for (uint i; i < buddiesTouched.length; i++) {
            uint got = buddy.bud(buddiesTouched[i]);

            assertTrue(got == 0 || got == 1);
        }
    }
}

// -- Invariant Helper Contract --
//
// Modified from horsefacts.eth's [article](https://mirror.xyz/horsefacts.eth/Jex2YVaO65dda6zEyfM_-DXlXhOWCAoSpOx5PLocYgw).

contract Handler is CommonBase {
    using LibAddressSet for AddressSet;

    IBuddy public immutable buddy;

    AddressSet internal _ghost_buddiesTouched;

    function ghost_buddiesTouched() external view returns (address[] memory) {
        return _ghost_buddiesTouched.addrs;
    }

    constructor(IBuddy buddy_) {
        buddy = buddy_;
    }

    function kiss(address who) external {
        _ghost_buddiesTouched.add(who);
        buddy.kiss(who);
    }

    function diss(uint whoSeed) external {
        address who = _ghost_buddiesTouched.rand(whoSeed);

        buddy.diss(who);
    }
}

struct AddressSet {
    address[] addrs;
    mapping(address => bool) saved;
}

library LibAddressSet {
    function add(AddressSet storage s, address addr) internal {
        if (!s.saved[addr]) {
            s.addrs.push(addr);
            s.saved[addr] = true;
        }
    }

    function rand(AddressSet storage s, uint seed)
        internal
        view
        returns (address)
    {
        if (s.addrs.length > 0) {
            return s.addrs[seed % s.addrs.length];
        } else {
            return address(0);
        }
    }
}
