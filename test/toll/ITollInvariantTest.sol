// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {CommonBase} from "forge-std/Base.sol";

import {IToll} from "src/toll/IToll.sol";
import {IAuth} from "src/auth/IAuth.sol";

/**
 * @notice Provides IToll Invariant Tests.
 */
abstract contract ITollInvariantTest is Test {
    IToll toll;
    Handler handler;

    function setUp(IToll toll_) internal {
        toll = toll_;

        handler = new Handler(toll);
        IAuth(address(toll)).rely(address(handler));

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = Handler.kiss.selector;
        selectors[1] = Handler.diss.selector;

        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
        targetContract(address(handler));
    }

    function invariant_toll_onlyContainsTolledAddresses() public {
        address[] memory tolled = toll.tolled();

        for (uint i; i < tolled.length; i++) {
            assertTrue(toll.tolled(tolled[i]));
        }
    }

    function invariant_toll_containsAllTolledAddresses() public {
        address[] memory budsTouched = handler.ghost_budsTouched();
        address[] memory tolled = toll.tolled();

        for (uint i; i < budsTouched.length; i++) {
            // If touched bud is tolled...
            if (toll.tolled(budsTouched[i])) {
                // ...tolled list must contain it.
                for (uint j; j < tolled.length; j++) {
                    // Break inner loop if bud found.
                    if (tolled[j] == budsTouched[i]) {
                        break;
                    }

                    // Fail if tolled list does not tolled bud.
                    if (j == tolled.length - 1) {
                        assertTrue(false);
                    }
                }
            }
        }
    }

    function invariant_buds_imageIsZeroOne() public {
        address[] memory budsTouched = handler.ghost_budsTouched();

        for (uint i; i < budsTouched.length; i++) {
            uint got = toll.bud(budsTouched[i]);

            assertTrue(got == 0 || got == 1);
        }
    }
}

// -- Invariant Helper Contract --
//
// Modified from horsefacts.eth's [article](https://mirror.xyz/horsefacts.eth/Jex2YVaO65dda6zEyfM_-DXlXhOWCAoSpOx5PLocYgw).

contract Handler is CommonBase {
    using LibAddressSet for AddressSet;

    IToll public immutable toll;

    AddressSet internal _ghost_budsTouched;

    function ghost_budsTouched() external view returns (address[] memory) {
        return _ghost_budsTouched.addrs;
    }

    constructor(IToll toll_) {
        toll = toll_;
    }

    function kiss(address who) external {
        _ghost_budsTouched.add(who);
        toll.kiss(who);
    }

    function diss(uint whoSeed) external {
        address who = _ghost_budsTouched.rand(whoSeed);

        toll.diss(who);
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
