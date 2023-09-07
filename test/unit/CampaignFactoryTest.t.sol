// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../../src/Campaign.sol";
import {CampaignFactory} from "../../src/CampaignFactory.sol";
import {DeployCampaignFactory} from "../../script/DeployCampaignFactory.s.sol";

// https://book.getfoundry.sh/forge/cheatcodes -> Foundry cheatcodes

contract CampaignFactoryTest is Test {
    CampaignFactory campaignFactory;

    //https://book.getfoundry.sh/reference/forge-std/make-addr?highlight=makeAddr#makeaddr
    address USER = makeAddr("user");
    address campaignAddress;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployCampaignFactory deployCampaignFactory = new DeployCampaignFactory();
        campaignFactory = deployCampaignFactory.run();
    }

    function testDeployCampaignFactoryContract() public {
        address campaignFactoryAddress = campaignFactory.getContractAddress();
        assertEq(address(campaignFactory), campaignFactoryAddress);
    }

    function testDeployCampaignContract() public {
        // https://book.getfoundry.sh/cheatcodes/deal?highlight=deal#deal
        vm.deal(USER, STARTING_BALANCE);
        vm.prank(USER); // The next TX will be send by USER
        campaignFactory.createCampaignContract(1 ether);
        address[] memory deployedCampaigns = campaignFactory
            .getDeployedCampaigns();
        assertEq(deployedCampaigns.length, 1);
    }
}

// /* ### TEST COMMANDS ###
// forge test
// forge test --fork-url $SEPOLIA_ALCHEMY_RPC_URL
// forge test --mt testDeployCampaignFactory
// forge test --mt testDeployCampaignFactory -vv
// forge test --mt testDeployCampaignFactory -vvv
// forge test --mt testDeployCampaignFactory -vvv --fork-url $SEPOLIA_ALCHEMY_RPC_URL -> uses sepolia network to interac with AggregatorV3Interface contract
// forge test --mt testDeployCampaignFactory -vvvv --fork-url $SEPOLIA_ALCHEMY_RPC_URL
// forge coverage --fork-url $SEPOLIA_ALCHEMY_RPC_URL
// forge snapshot
// forge snapshot --mt testDeployCampaignFactory -> creates a new file with data on how much gas was spent for testing the function
// chisel -> opens Solidity environment in terminal https://book.getfoundry.sh/reference/chisel/?highlight=chisel#chisel
// */

// /*
// 1. Unit: Testing a single function
// 2. Integration: Testing multiple functions
// 3. Forked: Testing on a forked network
// 4. Staging: Testing on a live network (testnet or mainnet)
// */
