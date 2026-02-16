// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import "forge-std/Test.sol";
import "../src/ReputationCore.sol";

contract ReputationCoreTest is Test {
    ReputationCore public reputation;

    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);

    function setUp() public {
        vm.prank(owner);
        reputation = new ReputationCore();
    }

    function testConstructorInitialState() public {
        uint256 tokenId = reputation.walletToTokenId(owner);

        assertEq(tokenId, 1);

        (ReputationStorage.Level level, uint256 contributions, bool validated) = reputation.profiles(tokenId);

        assertEq(uint256(level), uint256(ReputationStorage.Level.GOLD));
        assertEq(contributions, 0);
        assertTrue(validated);

        assertEq(reputation.bronzeToSilver(), 5);
        assertEq(reputation.silverToGold(), 15);
    }

    function testMintPassport() public {
        vm.prank(user1);
        reputation.mintPassport();

        uint256 tokenId = reputation.walletToTokenId(user1);
        assertEq(tokenId, 2);
    }

    function testMintRevertsIfAlreadyMinted() public {
        vm.startPrank(user1);
        reputation.mintPassport();
        vm.expectRevert(ReputationCore.AlreadyMinted.selector);
        reputation.mintPassport();
        vm.stopPrank();
    }

    function testAddContribution() public {
        vm.prank(user1);
        reputation.mintPassport();

        vm.prank(user1);
        reputation.addContribution();

        uint256 tokenId = reputation.walletToTokenId(user1);
        (, uint256 contributions,) = reputation.profiles(tokenId);

        assertEq(contributions, 1);
    }

    function testAddContributionRevertsWithoutNFT() public {
        vm.prank(user1);
        vm.expectRevert(ReputationCore.NoNFT.selector);
        reputation.addContribution();
    }

    function testValidateLevel() public {
        vm.prank(user1);
        reputation.mintPassport();

        uint256 tokenId = reputation.walletToTokenId(user1);

        vm.prank(owner);
        reputation.validateLevel(tokenId);

        (,, bool validated) = reputation.profiles(tokenId);
        assertTrue(validated);
    }

    function testValidateRevertsIfNotGold() public {
        vm.prank(user1);
        reputation.mintPassport();

        vm.prank(user1);
        vm.expectRevert(ReputationCore.NotGold.selector);
        reputation.validateLevel(1);
    }

    function testUpgradeBronzeToSilver() public {
        vm.prank(user1);
        reputation.mintPassport();

        uint256 tokenId = reputation.walletToTokenId(user1);

        for (uint256 i; i < 5; i++) {
            vm.prank(user1);
            reputation.addContribution();
        }

        vm.prank(owner);
        reputation.validateLevel(tokenId);

        vm.prank(user1);
        reputation.upgradeLevel();

        (ReputationStorage.Level level,,) = reputation.profiles(tokenId);
        assertEq(uint256(level), uint256(ReputationStorage.Level.SILVER));
    }

    function testTransferReverts() public {
        vm.prank(user1);
        reputation.mintPassport();

        uint256 tokenId = reputation.walletToTokenId(user1);

        vm.prank(user1);
        vm.expectRevert();
        reputation.transferFrom(user1, user2, tokenId);
    }

    function testUpgradeSilverToGold() public {
        vm.prank(user1);
        reputation.mintPassport();

        uint256 tokenId = reputation.walletToTokenId(user1);

        for (uint256 i; i < 5; i++) {
            vm.prank(user1);
            reputation.addContribution();
        }

        vm.prank(owner);
        reputation.validateLevel(tokenId);

        vm.prank(user1);
        reputation.upgradeLevel();

        for (uint256 i; i < 10; i++) {
            vm.prank(user1);
            reputation.addContribution();
        }

        vm.prank(owner);
        reputation.validateLevel(tokenId);

        vm.prank(user1);
        reputation.upgradeLevel();

        (ReputationStorage.Level level,,) = reputation.profiles(tokenId);
        assertEq(uint256(level), uint256(ReputationStorage.Level.GOLD));
    }

    function testUpgradeRevertsInsufficientContributions() public {
        vm.prank(user1);
        reputation.mintPassport();

        vm.prank(owner);
        reputation.validateLevel(2);

        vm.prank(user1);
        vm.expectRevert();
        reputation.upgradeLevel();
    }

    function testUpgradeRevertsValidationRequired() public {
        vm.prank(user1);
        reputation.mintPassport();

        for (uint256 i; i < 5; i++) {
            vm.prank(user1);
            reputation.addContribution();
        }

        vm.prank(user1);
        vm.expectRevert(ReputationCore.ValidationRequired.selector);
        reputation.upgradeLevel();
    }

    function testValidateRevertsInvalidToken() public {
        vm.prank(owner);
        vm.expectRevert(ReputationCore.InvalidToken.selector);
        reputation.validateLevel(999);
    }

    function testSetThresholds() public {
        vm.prank(owner);
        reputation.setThresholds(10, 20);

        assertEq(reputation.bronzeToSilver(), 10);
        assertEq(reputation.silverToGold(), 20);
    }

    function testSetThresholdsRevertsInvalidThreshold() public {
        vm.prank(owner);
        vm.expectRevert(ReputationCore.InvalidThreshold.selector);
        reputation.setThresholds(0, 10);

        vm.prank(owner);
        vm.expectRevert(ReputationCore.InvalidThreshold.selector);
        reputation.setThresholds(10, 5);
    }

    function testTokenURI() public {
        vm.prank(user1);
        reputation.mintPassport();

        uint256 tokenId = reputation.walletToTokenId(user1);
        string memory uri = reputation.tokenURI(tokenId);

        assertTrue(bytes(uri).length > 0);
    }

    function testTokenURIRevertsNonExistent() public {
        vm.expectRevert();
        reputation.tokenURI(999);
    }
}
