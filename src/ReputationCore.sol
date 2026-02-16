// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import "./ReputationStorage.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

/// @title Reputation Passport
/// @author Carlos Agudo
/// @notice Soulbound ERC-721 NFT for on-chain identity and reputation
/// @dev Storage is separated in ReputationStorage, this contract handles core logic
contract ReputationCore is ReputationStorage, Ownable {
    using Strings for uint256;

    /// @notice Minimum contributions required to upgrade from Bronze to Silver
    uint256 public bronzeToSilver = 5;

    /// @notice Minimum contributions required to upgrade from Silver to Gold
    uint256 public silverToGold = 15;

    /// @notice Emitted when a new NFT is minted
    event MintPassport(address indexed user, uint256 tokenId);

    /// @notice Emitted when a contribution is added
    event ContributionAdded(address indexed user, uint256 tokenId, uint256 totalContributions);

    /// @notice Emitted when a token is validated by a Gold
    event validatedByGold(address indexed validator, uint256 tokenId);

    /// @notice Emitted when a level upgrade occurs
    event LevelUpgraded(uint256 tokenId, Level newLevel);

    /// @notice Emitted when upgrade thresholds are updated
    event ThresholdsUpdated(uint256 bronzeToSilver, uint256 silverToGold);

    error AlreadyMinted();
    error NoNFT();
    error NotGold();
    error InvalidToken();
    error InsufficientContributions(uint256 required);
    error ValidationRequired();
    error InvalidThreshold();

    /// @dev Restrict access to Gold-level users
    modifier onlyGold() {
        uint256 tokenId = walletToTokenId[msg.sender];
        if (tokenId == 0) revert NoNFT();
        if (profiles[tokenId].level != Level.GOLD) revert NotGold();
        _;
    }

    /// @notice Deploys the contract and mints the first Gold token to the deployer
    /// @dev currentTokenId starts at 1 for the first Gold
    constructor() ReputationStorage("Reputation Passport", "RPASS") Ownable(msg.sender) {
        currentTokenId = 1;
        _mint(msg.sender, currentTokenId);
        profiles[currentTokenId] = Profile(Level.GOLD, 0, true);
        walletToTokenId[msg.sender] = currentTokenId;
    }

    /// @notice Mint a new Reputation Passport for a wallet
    function mintPassport() external {
        if (walletToTokenId[msg.sender] != 0) revert AlreadyMinted();

        currentTokenId++;
        uint256 tokenId = currentTokenId;

        _mint(msg.sender, tokenId);
        profiles[tokenId] = Profile(Level.BRONZE, 0, false);
        walletToTokenId[msg.sender] = tokenId;

        emit MintPassport(msg.sender, tokenId);
    }

    // @notice Add a contribution to your profile
    function addContribution() external {
        uint256 tokenId = walletToTokenId[msg.sender];
        if (tokenId == 0) revert NoNFT();

        profiles[tokenId].contributions++;
        emit ContributionAdded(msg.sender, tokenId, profiles[tokenId].contributions);
    }

    /// @notice Validate another user's level (only Gold)
    /// @param tokenIdToValidate Token ID of the user being validated
    function validateLevel(uint256 tokenIdToValidate) external onlyGold {
        if (tokenIdToValidate == 0 || tokenIdToValidate > currentTokenId) {
            revert InvalidToken();
        }

        profiles[tokenIdToValidate].validatedByGold = true;
        emit validatedByGold(msg.sender, tokenIdToValidate);
    }

    /// @notice Upgrade your level based on contributions and validation
    function upgradeLevel() external {
        uint256 tokenId = walletToTokenId[msg.sender];
        if (tokenId == 0) revert NoNFT();

        Profile storage profile = profiles[tokenId];

        if (profile.level == Level.BRONZE) {
            if (profile.contributions < bronzeToSilver) {
                revert InsufficientContributions(profile.contributions);
            }
            if (!profile.validatedByGold) revert ValidationRequired();
            profile.level = Level.SILVER;
            emit LevelUpgraded(tokenId, Level.SILVER);
        } else if (profile.level == Level.SILVER) {
            if (profile.contributions < silverToGold) {
                revert InsufficientContributions(profile.contributions);
            }
            if (!profile.validatedByGold) revert ValidationRequired();
            profile.level = Level.GOLD;
            emit LevelUpgraded(tokenId, Level.GOLD);
        }
    }

    /// @notice Updates contribution thresholds for level upgrades
    /// @dev Only callable by contract owner
    function setThresholds(uint256 _bronze, uint256 _silver) external onlyOwner {
        if (_bronze == 0 || _silver <= _bronze) revert InvalidThreshold();
        bronzeToSilver = _bronze;
        silverToGold = _silver;

        emit ThresholdsUpdated(_bronze, _silver);
    }

    /// @notice Returns on-chain metadata JSON for a token
    /// @param tokenId The token ID to query
    /// @return JSON string representing metadata
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        Profile memory profile = profiles[tokenId];
        string memory levelStr =
            profile.level == Level.BRONZE ? "Bronze" : profile.level == Level.SILVER ? "Silver" : "Gold";

        return string(
            abi.encodePacked(
                '{"name":"Reputation Passport #',
                tokenId.toString(),
                '","description":"Non-transferable on-chain identity primitive",',
                '"attributes":[{"trait_type":"Level","value":"',
                levelStr,
                '"},{"trait_type":"Contributions","value":"',
                profile.contributions.toString(),
                '"}]}'
            )
        );
    }

    /// @dev Prevent NFT transfers (soulbound)
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert("Soulbound: cannot transfer");
        }
        return super._update(to, tokenId, auth);
    }
}
