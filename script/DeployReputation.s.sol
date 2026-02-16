// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import "forge-std/Script.sol";
import "../src/ReputationCore.sol";

contract DeployReputation is Script {
    function run() external returns (ReputationCore) {
        vm.startBroadcast();

        ReputationCore reputation = new ReputationCore();

        vm.stopBroadcast();

        console.log("ReputationCore deployed at:", address(reputation));
        console.log("Bronze -> Silver threshold:", reputation.bronzeToSilver());
        console.log("Silver -> Gold threshold:", reputation.silverToGold());

        uint256 ownerTokenId = reputation.walletToTokenId(msg.sender);
        console.log("Owner Token ID:", ownerTokenId);

        return reputation;
    }
}
