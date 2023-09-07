// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {CampaignFactory} from "../src/CampaignFactory.sol";
import {Campaign} from "../src/Campaign.sol";

// import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployCampaignFactory is Script {
    function run() external returns (CampaignFactory) {
        // everything before startBroadcast() is not a "real" transaction
        vm.startBroadcast();
        // everything after startBroadcast() is a "real" transaction
        CampaignFactory campaignFactory = new CampaignFactory();
        vm.stopBroadcast();
        return campaignFactory;
    }
}
