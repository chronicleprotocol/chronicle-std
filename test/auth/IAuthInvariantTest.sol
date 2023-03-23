// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {CommonBase} from "forge-std/Base.sol";

import {IAuth} from "src/auth/IAuth.sol";

/**
 * @notice Provides IAuth Invariant Tests.
 */
abstract contract IAuthInvariantTest is Test {
    IAuth auth;
    Handler handler;

    function setUp(IAuth auth_) internal {
        auth = auth_;

        handler = new Handler(auth);
        auth.rely(address(handler));

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = Handler.rely.selector;
        selectors[1] = Handler.deny.selector;

        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
        targetContract(address(handler));
    }

    function invariant_authed_onlyContainsAuthedAddresses() public {
        address[] memory authed = auth.authed();

        for (uint i; i < authed.length; i++) {
            assertTrue(auth.authed(authed[i]));
        }
    }

    function invariant_authed_containsAllAuthedAddresses() public {
        address[] memory wardsTouched = handler.ghost_wardsTouched();
        address[] memory authed = auth.authed();

        for (uint i; i < wardsTouched.length; i++) {
            // If touched ward is auth'ed...
            if (auth.authed(wardsTouched[i])) {
                // ...authed list must contain it.
                for (uint j; j < authed.length; j++) {
                    // Break inner loop if ward found.
                    if (authed[j] == wardsTouched[i]) {
                        break;
                    }

                    // Fail if authed list does not contain auth'ed ward.
                    if (j == authed.length - 1) {
                        assertTrue(false);
                    }
                }
            }
        }
    }

    function invariant_wards_imageIsZeroOne() public {
        address[] memory wardsTouched = handler.ghost_wardsTouched();

        for (uint i; i < wardsTouched.length; i++) {
            uint got = auth.wards(wardsTouched[i]);

            assertTrue(got == 0 || got == 1);
        }
    }
}

// -- Invariant Helper Contract --
//
// Modified from horsefacts.eth's [article](https://mirror.xyz/horsefacts.eth/Jex2YVaO65dda6zEyfM_-DXlXhOWCAoSpOx5PLocYgw).

contract Handler is CommonBase {
    using LibAddressSet for AddressSet;

    IAuth public immutable auth;

    AddressSet internal _ghost_wardsTouched;

    function ghost_wardsTouched() external view returns (address[] memory) {
        return _ghost_wardsTouched.addrs;
    }

    constructor(IAuth auth_) {
        auth = auth_;
    }

    function rely(uint callerSeed, address who) external {
        _ghost_wardsTouched.add(who);

        // Use random ward touched as caller, if auth'ed.
        // Otherwise use address(this).
        address caller = _ghost_wardsTouched.rand(callerSeed);
        caller = auth.authed(caller) ? caller : address(this);
        vm.startPrank(caller);

        auth.rely(who);
    }

    function deny(uint callerSeed, uint whoSeed) external {
        // Use random ward touched as caller, if auth'ed.
        // Otherwise use address(this).
        address caller = _ghost_wardsTouched.rand(callerSeed);
        caller = auth.authed(caller) ? caller : address(this);
        vm.startPrank(caller);

        // Renounce auth of random ward touched.
        // Note to not renounce auth for address(this).
        address who = _ghost_wardsTouched.rand(whoSeed);
        who = who != address(this) ? who : address(0);

        auth.deny(who);
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
