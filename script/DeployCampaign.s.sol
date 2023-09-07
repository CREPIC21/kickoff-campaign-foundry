// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Campaign} from "../src/Campaign.sol";

// import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployCampaign is Script {
    function run() external returns (Campaign) {
        // everything before startBroadcast() is not a "real" transaction
        address USER = makeAddr("user");
        uint256 MINIMUM_CONTRIBUTION = 1 ether;
        uint256 STARTING_BALANCE = 10 ether;
        // https://book.getfoundry.sh/cheatcodes/deal?highlight=deal#deal
        vm.deal(USER, STARTING_BALANCE);

        vm.startBroadcast();
        // everything after startBroadcast() is a "real" transaction
        Campaign campaign = new Campaign(MINIMUM_CONTRIBUTION, USER);
        vm.stopBroadcast();
        return campaign;
    }
}
