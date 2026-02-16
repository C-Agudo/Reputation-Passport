// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

/// @title Reputation Storage
/// @author Carlos Agudo
/// @notice Storage layer for Reputation Passport ERC-721
/// @dev Contains all data structures and mappings; no business logic here
contract ReputationStorage is ERC721 {
    /// @notice Different levels of reputation
    enum Level {
        BRONZE,
        SILVER,
        GOLD
    }

    /// @notice Profile struct for each token
    /// @dev Stores level, contribution count, and Gold validation flag
    struct Profile {
        Level level;
        uint256 contributions;
        bool validatedByGold;
    }

    /// @notice Mapping from token ID to Profile
    mapping(uint256 => Profile) public profiles;

    /// @notice Mapping from wallet address to token ID
    mapping(address => uint256) public walletToTokenId;

    /// @notice Counter to track the latest minted token ID
    uint256 public currentTokenId;

    /// @notice Constructor to set token name and symbol
    /// @param name_ Name of the ERC-721 token
    /// @param symbol_ Symbol of the ERC-721 token
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}
}
