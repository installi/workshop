// SPDX-License-Identifier: SimPL-2.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Authority is Ownable {
    // Member of administrator or contract
    mapping (string => address) public _members;

    // Permit of members
    mapping (address => mapping(string => bool)) public _permits;

    /**
     * @notice Set member of administrator or contract
     *
     * @param member_ member's address
     * @param name_   name of member
     *
     * This function is onwer only
     */
    function setMember(address member_, string memory name_)
        external onlyOwner {
        
        _members[name_] = member_;
    }

    /**
     * @notice Set member's permit
     *
     * @param member_ member's address
     * @param permit_ name of permit
     * @param enable_ enable this member's permit
     *
     * This function is onwer only
     */
    function setPermit(address member_, string memory permit_, bool enable_)
        external onlyOwner {
        
        _permits[member_][permit_] = enable_;
    }
}