// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Campaign} from "./Campaign.sol";

// /**
//  * @title Campaign Factory Contract
//  * @author Danijel Crepic
//  * @notice This contract allows users to create new Campaign Contracts, each corresponding to a distinct project or fundraising campaign
//  * @dev
//  */

contract CampaignFactory {
    address[] public listOfDeployedCampaignContracts;

    // function that creates new Campaign contract
    function createCampaignContract(uint256 minimum) public {
        Campaign newCampaign = new Campaign(minimum, msg.sender); // we need to pass msg.sender otherwise the CampaignFactory contract will be the manager of every new deployed Campaign contract
        listOfDeployedCampaignContracts.push(address(newCampaign)); // Store the address of the newCampaign contract
    }

    // function that will return all deployed Campaign contracts
    function getDeployedCampaigns() public view returns (address[] memory) {
        return listOfDeployedCampaignContracts;
    }

    // function that will return Campaign Factory Contract address
    function getContractAddress() public view returns (address) {
        return address(this);
    }
}
