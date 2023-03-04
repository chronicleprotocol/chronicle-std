// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {IConfigurable} from "./IConfigurable.sol";

/**
 * @title Configurable Module
 *
 * @dev The `Configurable` contract module provides a function
 *      `file(bytes32,bytes)` function to configure files.
 *
 *      A contract inheriting from `Configurable` is said to be _configurable_.
 *
 *      The function SHOULD be overriden in the downstream contract.
 *
 *      The function MUST fail with `InvalidFile(bytes32)` if given file
 *      is not configurable and `InvalidValueFiled(bytes32,bytes)` if given
 *      value is invalid for given file.
 *
 *      The function MUST emit the `Filed(address,bytes32,bytes)` event.
 *
 *      A contract inheriting from `Configurable` SHOULD only be configurable
 *      via the provided `file(bytes32,bytes)` function.
 */
abstract contract Configurable is IConfigurable {
    /// @inheritdoc IConfigurable
    ///
    /// @dev Should be overriden in dowmstream contract.
    ///
    /// @custom:example Example using custom formatting.
    /// ```solidity
    /// function file(bytes32 file_, bytes calldata value) external auth {
    ///     // forgefmt: disable-start
    ///     if      (file_ == "version") version = abi.decode(value, (string));
    ///     else if (file_ == "fee")     fee     = abi.decode(value, (uint));
    ///     else revert InvalidFile(file_);
    ///     // forgefmt: disable-end
    ///
    ///     emit Filed(msg.sender, file_, value);
    /// }
    /// ```
    ///
    /// @custom:example Example using `InvalidValueFiled(bytes32,bytes)` error.
    /// ```solidity
    /// function file(bytes32 file_, bytes calldata value) external auth {
    ///     if (file_ == "fee") {
    ///         uint fee_ = abi.decode(value, (uint));
    ///         if (fee_ > MAX_FEE) revert InvalidValueFiled(file_, value);
    ///         fee = fee_;
    ///     } else {
    ///         revert InvalidFile(file_);
    ///     }
    ///
    ///     emit Filed(msg.sender, file_, value);
    /// }
    /// ```
    function file(bytes32 file_, bytes calldata /*value*/ )
        external
        virtual
        override(IConfigurable);
}
