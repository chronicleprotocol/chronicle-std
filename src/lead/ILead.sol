// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface ILead {
    /// @notice Thrown by protected function if caller not leader.
    /// @param caller The caller's address.
    error NotLeader(address caller);

    /// @notice Emitted when lead granted to address.
    /// @param caller The caller's address.
    /// @param who The address lead got granted to.
    event LeadGranted(address indexed caller, address indexed who);

    /// @notice Emitted when lead renounced from address.
    /// @param caller The caller's address.
    /// @param who The address lead got renounced from.
    event LeadRenounced(address indexed caller, address indexed who);

    /// @notice Grants address `who` lad.
    /// @dev Only callable by auth'ed address.
    /// @param who The address to grant lad.
    function hail(address who) external;

    /// @notice Renounces address `who`'s lead.
    /// @dev Only callable by auth'ed address.
    /// @param who The address to renounce lead.
    function fear(address who) external;

    /// @notice Returns whether address `who` is leader.
    /// @param who The address to check.
    /// @return True if `who` is leader, false otherwise.
    function leader(address who) external view returns (bool);

    /// @notice Returns full list of addresses granted lead.
    /// @dev May contain duplicates.
    /// @return List of addresses granted lead.
    function leader() external view returns (address[] memory);
}
