// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {CampaignFactory} from "../../src/CampaignFactory.sol";
import {DeployCampaignFactory} from "../../script/DeployCampaignFactory.s.sol";

contract DeployCampaignFactoryTest is Test {
    CampaignFactory campaignFactory;
    DeployCampaignFactory deployCampaignFactory;

    function setUp() external {
        deployCampaignFactory = new DeployCampaignFactory();
    }

    function testCampaignFactoryContractDeployment() public {
        // Deploy a campaignFactory using the DeployCampaignfactory contract
        campaignFactory = deployCampaignFactory.run();
        address campaignFactoryAddress = campaignFactory.getContractAddress();
        assertEq(address(campaignFactory), campaignFactoryAddress);
    }
}
