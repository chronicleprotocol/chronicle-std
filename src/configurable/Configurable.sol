// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IConfigurable} from "./IConfigurable.sol";

/**
 * @title Configurable Module
 *
 * @dev The `Configurable` contract module provides a function
 *      `file(bytes32,bytes)` function to configure files.
 *
 *      A contract inheriting from `Configurable` is said to be _configurable_.
 */
abstract contract Configurable is IConfigurable {
    /// @inheritdoc IConfigurable
    ///
    /// @dev Must be overriden in downstream contract.
    /// @dev Must fail with `InvalidFile(bytes32)` if given file not
    ///      configurable.
    /// @dev Must fail with `InvalidValueFiled(bytes32,bytes)` if given value
    ///      invalid for given file.
    /// @dev Must emit the `Filed(address,bytes32,bytes)` event if file
    ///      mutated.
    ///
    /// @custom:example Example with simple dispatching and decoding.
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
