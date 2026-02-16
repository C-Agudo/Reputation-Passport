// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import "forge-std/Script.sol";
import "../src/ReputationCore.sol";

contract DemoFlow is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address user1 = vm.addr(2);
        address user2 = vm.addr(3);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy
        ReputationCore reputation = new ReputationCore();
        console.log("Deployed at:", address(reputation));

        vm.stopBroadcast();

        // User1 mints
        vm.startPrank(user1);
        reputation.mintPassport();
        vm.stopPrank();

        uint256 tokenId = reputation.walletToTokenId(user1);
        console.log("User1 tokenId:", tokenId);

        // Add contributions
        for (uint256 i; i < 5; i++) {
            vm.prank(user1);
            reputation.addContribution();
        }

        console.log("User1 contributions added");

        // Gold validates (deployer is GOLD)
        vm.prank(vm.addr(deployerPrivateKey));
        reputation.validateLevel(tokenId);

        console.log("Validated by Gold");

        // Upgrade
        vm.prank(user1);
        reputation.upgradeLevel();

        console.log("User1 upgraded to SILVER");

        // Governance update
        vm.prank(vm.addr(deployerPrivateKey));
        reputation.setThresholds(10, 25);

        console.log("Thresholds updated");
        console.log("New Bronze -> Silver:", reputation.bronzeToSilver());
        console.log("New Silver -> Gold:", reputation.silverToGold());
    }
}
