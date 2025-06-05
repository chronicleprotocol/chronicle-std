// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {CommonBase} from "forge-std/Base.sol";

import {ILead} from "src/lead/ILead.sol";
import {IAuth} from "src/auth/IAuth.sol";

/**
 * @notice Provides ILead Invariant Tests.
 */
abstract contract ILeadInvariantTest is Test {
    ILead lead;
    Handler handler;

    function setUp(ILead lead_) internal {
        lead = lead_;

        handler = new Handler(lead);
        IAuth(address(lead)).rely(address(handler));

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = Handler.hail.selector;
        selectors[1] = Handler.fear.selector;

        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
        targetContract(address(handler));
    }

    function invariant_lead_onlyContainsLeaderAddresses() public {
        address[] memory leader = lead.leader();

        for (uint i; i < leader.length; i++) {
            assertTrue(lead.leader(leader[i]));
        }
    }

    function invariant_lead_containsAllLeaderAddresses() public {
        address[] memory chefsTouched = handler.ghost_chefsTouched();
        address[] memory leader = lead.leader();

        for (uint i; i < chefsTouched.length; i++) {
            // If touched chef is leader...
            if (lead.leader(chefsTouched[i])) {
                // ...leader list must contain it.
                for (uint j; j < leader.length; j++) {
                    // Break inner loop if chef found.
                    if (leader[j] == chefsTouched[i]) {
                        break;
                    }

                    // Fail if leader list does not leader chef.
                    if (j == leader.length - 1) {
                        assertTrue(false);
                    }
                }
            }
        }
    }
}

// -- Invariant Helper Contract --
//
// Modified from horsefacts.eth's [article](https://mirror.xyz/horsefacts.eth/Jex2YVaO65dda6zEyfM_-DXlXhOWCAoSpOx5PLocYgw).

contract Handler is CommonBase {
    using LibAddressSet for AddressSet;

    ILead public immutable lead;

    AddressSet internal _ghost_chefsTouched;

    function ghost_chefsTouched() external view returns (address[] memory) {
        return _ghost_chefsTouched.addrs;
    }

    constructor(ILead lead_) {
        lead = lead_;
    }

    function hail(address who) external {
        _ghost_chefsTouched.add(who);
        lead.hail(who);
    }

    function fear(uint whoSeed) external {
        address who = _ghost_chefsTouched.rand(whoSeed);

        lead.fear(who);
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
