// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../../src/Campaign.sol";
import {DeployCampaign} from "../../script/DeployCampaign.s.sol";

contract DeployCampaignTest is Test {
    Campaign campaign;
    DeployCampaign deployCampaign;

    function setUp() external {
        deployCampaign = new DeployCampaign();
        // campaign = deployCampaign.run();
    }

    function testCampaignContractDeployment() public {
        // Deploy a campaign using the DeployCampaign contract
        campaign = deployCampaign.run();
        address campaignAddress = campaign.getContractAddress();
        assertEq(address(campaign), campaignAddress);
    }
}
