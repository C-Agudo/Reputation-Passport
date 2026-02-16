# Reputation Passport (ERC-721)

[![Solidity](https://img.shields.io/badge/Solidity-0.8.33-blue)](https://docs.soliditylang.org/)
[![Network](https://img.shields.io/badge/Network-Arbitrum%20One-lightgrey)](https://arbitrum.io/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## Overview
**Reputation Passport** is a **soulbound ERC-721 NFT**, designed as a **reusable on-chain identity and reputation primitive**.

- Unique identity per wallet (soulbound)
- Hierarchical reputation levels: Bronze → Silver → Gold
- Social validation of contributions
- Fully on-chain JSON metadata, no IPFS or images
- Protocol-oriented, minimal and low-cost deployment

<details>
<summary>Objectives</summary>

### Objectives
- Provide a reusable on-chain **reputation primitive**.
- Enable **unique identity per wallet** (soulbound).
- Implement a **hierarchical level system**: Bronze → Silver → Gold.
- Allow **social validation of contributions**.
- Serve as a **protocol-oriented showcase** for on-chain reputation management.

</details>

<details>
<summary>Key Concepts</summary>

| Concept          | Description |
|-----------------|------------|
| **Soulbound NFT** | Non-transferable, one NFT per wallet. |
| **Levels**       | Bronze, Silver, Gold. |
| **Contributions** | Counter representing user participation. |
| **Validation**    | Only Gold-level users can approve level upgrades. |
| **Metadata**     | JSON generated fully on-chain, no images required. |

</details>

<details>
<summary>Level Hierarchy</summary>

### Bronze
- Default level after minting
- Contributions are free to add

### Silver
- Minimum contributions required
- Validated by any Gold user

### Gold
- Higher number of contributions required
- Validated by an existing Gold user
- **First Gold** is the contract deployer
- Unlimited number of Gold users

</details>

<details>
<summary>Contribution Logic</summary>

- Users increment their contributions via `addContribution()`
- Contributions themselves are **not automatically verified**
- Level upgrades depend on **Gold validation** to create social filtering and anti-Sybil resistance

</details>

<details>
<summary>Main Functions</summary>

```solidity
// Mint a soulbound NFT
function mintPassport() external;

// Add a contribution
function addContribution() external;

// Validate level (only GOLD)
function validateLevel(address user) external onlyGold;

// Query functions
function getLevel(address user) external view returns (Level);
function getContributions(address user) external view returns (uint256);

// On-chain metadata
function tokenURI(uint256 tokenId) public view override returns (string memory);

<details>
<summary>On-Chain Metadata Example</summary>

```json
{
  "name": "Reputation Passport #1",
  "description": "Non-transferable on-chain identity primitive",
  "attributes": [
    { "trait_type": "Level", "value": "Silver" },
    { "trait_type": "Contributions", "value": 7 }
  ]
}

</details> <details> <summary>Security Considerations</summary>

- Soulbound: _transfer overridden to prevent transfers

- One NFT per wallet: prevents duplicates

- Gold validation: ensures integrity of level upgrades

- Sybil protection: reaching Gold requires approval from an existing Gold user

</details> <details> <summary>Deployment</summary>

- Network: Arbitrum One

- Tools: Foundry / Hardhat

- Gas: Low, no staking or external tokens required

- Interactions: mint, addContribution, validateLevel — all cheap on L2

</details> <details> <summary>Professional Purpose</summary>

- This project demonstrates:

- Design of a reusable identity and reputation primitive

- Protocol-oriented thinking with ERC-721

- Advanced on-chain metadata handling

- Hierarchical social validation without off-chain dependencies

- Readiness for integration into DAOs, marketplaces, or governance systems

</details>