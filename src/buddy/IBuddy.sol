// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

interface IBuddy {
    /// @notice Thrown by protected function if caller not buddy.
    /// @param caller The caller's address.
    error NotBuddy(address caller);

    /// @param caller The caller's address.
    /// @param who The address kissed.
    event BuddyKissed(address indexed caller, address indexed who);

    /// @param caller The caller's address.
    /// @param who The address dissed.
    event BuddyDissed(address indexed caller, address indexed who);

    /// @notice Kisses address `who`, making them a buddy.
    /// @dev Only callable by auth'ed addresses.
    /// @param who The address to kiss.
    function kiss(address who) external;

    /// @notice Disses address `who`, renouncing them from being a buddy.
    /// @dev Only callable by auth'ed addresses.
    /// @param who The address to diss.
    function diss(address who) external;

    /// @notice Returns whether address `who` is buddy.
    /// @param who The address to check.
    /// @return True if `who` is buddy, false otherwise.
    function buddies(address who) external view returns (bool);

    /// @notice Returns full list of buddies.
    /// @dev May contain duplicates.
    /// @return List of buddies.
    function buddies() external view returns (address[] memory);

    /// @notice Returns whether address `who` is buddy.
    /// @custom:deprecated Use `buddies(address)(bool)` instead.
    /// @param who The address to check.
    /// @return 1 if `who` is buddy, 0 otherwise.
    function bud(address who) external view returns (uint);
}
