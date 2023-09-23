// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Campaign} from "../../src/Campaign.sol";
import {DeployCampaign} from "../../script/DeployCampaign.s.sol";

// https://book.getfoundry.sh/forge/cheatcodes -> Foundry cheatcodes

contract CampaignTest is Test {
    Campaign campaign;

    //https://book.getfoundry.sh/reference/forge-std/make-addr?highlight=makeAddr#makeaddr
    address OWNER = makeAddr("user");
    address CONTRIBUTOR = makeAddr("contributor");
    address CONTRIBUTOR_TWO = makeAddr("contributor-two");
    address CONTRIBUTOR_THREE = makeAddr("contributor-three");
    address RECIPIENT = makeAddr("recipient");
    address campaignAddress;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployCampaign deployCampaign = new DeployCampaign();
        campaign = deployCampaign.run();
        // https://book.getfoundry.sh/cheatcodes/deal?highlight=deal#deal
        vm.deal(CONTRIBUTOR, STARTING_BALANCE);
        vm.deal(CONTRIBUTOR_TWO, STARTING_BALANCE);
        vm.deal(CONTRIBUTOR_THREE, STARTING_BALANCE);
    }

    function testOwnerIsMsgSender() public {
        address manager = campaign.getManager();
        // console.log(manager);
        // console.log(OWNER);
        assertEq(manager, OWNER);
    }

    function testMinimumContributionIsDonated() public {
        // Arrange
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        // Act / Assert
        vm.expectRevert(Campaign.Campaign__NotEnoughEthSent.selector); // the next line should revert, it should fail
        campaign.contribute{value: 0.9 ether}(); // sending 0.9 ether value when we should send 1 ether
    }

    function testWhenContributorSendsMinimumContributionMappingForSenderIsSetToTrue()
        public
    {
        // Arrange
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        // Act
        campaign.contribute{value: 2 ether}();
        bool didContribute = campaign.checkIfContributorDonatedMoney(
            CONTRIBUTOR
        );
        // Assert
        assertTrue(didContribute);
    }

    function testWhenContributorSendsMinimumContributionApproversCountIncreases()
        public
    {
        // Arrange
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        // Act
        campaign.contribute{value: 2 ether}();
        uint256 approversCount = campaign.getApproversCount();
        // Assert
        assertEq(approversCount, 1);
    }

    function testWhenContributorSendsMinimumContributionAgainApproversCountDoesNotIncrease()
        public
    {
        // Arrange
        vm.startPrank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        // Act
        campaign.contribute{value: 2 ether}();
        uint256 approversCountAfterFirstContribution = campaign
            .getApproversCount();

        campaign.contribute{value: 2 ether}();
        uint256 approversCountAfterSecondContribution = campaign
            .getApproversCount();
        vm.stopPrank();
        // Assert
        assertEq(
            approversCountAfterFirstContribution,
            approversCountAfterSecondContribution
        );
    }

    function testOnlyManagerCanCallCreateRequest() public {
        // Arrange
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        vm.expectRevert(
            Campaign.Campaign__ManagerDidNotCallThisFunction.selector
        ); // the next line should revert, it should fail
        campaign.createRequest("Delivery cost", 1 ether, RECIPIENT);
    }

    function testRevertWhenCreateingRequestAndContractDoesNothaveEnoughBalanceForTheRequestedAmount()
        public
    {
        // Arrange
        vm.prank(OWNER); // The next TX will be send by CONTRIBUTOR
        vm.expectRevert(
            Campaign
                .Campaign__RequestCanNotBeCreatedAsContractDoesNotHaveEnoughBalanceForRequestValue
                .selector
        ); // the next line should revert, it should fail as contract has 1 ETH of balance and request is for 3 ETH
        campaign.createRequest("Delivery cost", 3 ether, RECIPIENT);
    }

    function testOnceManagerCreatesRequestNewRequestIsAddedToRequestStruct()
        public
    {
        // Arange
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        campaign.contribute{value: 2 ether}();
        vm.prank(OWNER); // The next TX will be send by OWNER
        // Act
        campaign.createRequest("Delivery cost", 1 ether, RECIPIENT);
        (
            string memory requestDescription,
            uint256 requestValue,
            address requestRecipient,
            bool complete,
            uint256 approvalCount
        ) = campaign.getRequest(0);
        // Assert
        assertEq(
            requestDescription,
            "Delivery cost",
            "Request description should match"
        );
        assertEq(requestValue, 1 ether, "Request value should match");
        assertEq(requestRecipient, RECIPIENT, "Request recipient should match");
        assertEq(complete, false, "Request should not be marked as complete");
        assertEq(approvalCount, 0, "Approval count should be 0");
    }

    modifier createRequest() {
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        campaign.contribute{value: 2 ether}();
        vm.prank(OWNER); // The next TX will be send by OWNER
        campaign.createRequest("Delivery cost", 1 ether, RECIPIENT);
        _;
    }

    function testToCheckIfRequestWasAlreadyFinalizedWhenContributorWantsToApproveIt()
        public
    {
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        campaign.contribute{value: 2 ether}();
        vm.prank(OWNER); // The next TX will be send by OWNER
        campaign.createRequest("Delivery cost", 1 ether, RECIPIENT);
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        campaign.approveRequest(0);
        vm.prank(OWNER); // The next TX will be send by OWNER
        campaign.finalizeRequest(0);

        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        vm.expectRevert(Campaign.Campaign__RequestWasAlreadyFinalized.selector); // the next line should revert, it should fail as CONTRIBUTOR will try to approve request that was already finalized
        campaign.approveRequest(0);
    }

    function testToCheckIfPersonApprovingRequestIsNotManager()
        public
        createRequest
    {
        vm.prank(OWNER); // The next TX will be send by OWNER
        vm.expectRevert(
            Campaign.Campaign__ManagerCanNotApproveRequest.selector
        ); // the next line should revert, it should fail as OWNER will try to approve request and not the contributor
        campaign.approveRequest(0);
    }

    function testToCheckIfPersonApprovingRequestIsOnTheListOfContributors()
        public
        createRequest
    {
        vm.prank(CONTRIBUTOR_TWO); // The next TX will be send by CONTRIBUTOR_TWO
        vm.expectRevert(Campaign.Campaign__ApproverIsNotContributor.selector); // the next line should revert, it should fail as OWNER will try to approve request and not the contributor
        campaign.approveRequest(0);
    }

    function testToCheckIfPersonApprovingRequestDidNotAlreadyApprovedTheSameRequest()
        public
        createRequest
    {
        // Arrange
        vm.startPrank(CONTRIBUTOR); // The next transactions will be send by CONTRIBUTOR
        campaign.approveRequest(0);
        vm.expectRevert(
            Campaign.Campaign__ApproverAlreadyVotedForThisRequest.selector
        ); // the next line should revert, it should fail as CONTRIBUTOR will try to approve the same request again
        campaign.approveRequest(0);
        vm.stopPrank();
    }

    function testToCheckIfPersonApprovingIsAddedToApprovalsMapping()
        public
        createRequest
    {
        // Arrange
        vm.startPrank(CONTRIBUTOR); // The next transactions will be send by CONTRIBUTOR
        campaign.approveRequest(0);
        vm.stopPrank();
        bool approved = campaign.getApprovalStatusOfApprover(0, CONTRIBUTOR);
        assertTrue(approved);
    }

    function testToCheckIfApprovalCountForRequestIncreaseWhenContributerApprovesTheRequest()
        public
        createRequest
    {
        // Arrange
        vm.startPrank(CONTRIBUTOR); // The next transactions will be send by CONTRIBUTOR
        campaign.approveRequest(0);
        vm.stopPrank();
        (, , , , uint256 approvalCount) = campaign.getRequest(0);
        assertEq(approvalCount, 1, "Approval count should be 0");
    }

    function testOnlyManagerCanCallFinalizeRequest() public createRequest {
        // Arange
        vm.startPrank(CONTRIBUTOR); // The next transactions will be send by CONTRIBUTOR
        campaign.approveRequest(0);
        vm.expectRevert(
            Campaign.Campaign__ManagerDidNotCallThisFunction.selector
        ); // the next line should revert, it should fail as CONTRIBUTOR will try to finalize the request
        campaign.finalizeRequest(0);
        vm.stopPrank();
    }

    function testToCheckIfRequestIsNotMarkedAsCompleteWhenManagerWantsToFinalizeIt()
        public
        createRequest
    {
        vm.startPrank(CONTRIBUTOR); // The next transactions will be send by CONTRIBUTOR
        campaign.approveRequest(0);
        vm.stopPrank();
        vm.startPrank(OWNER); // The next transactions will be send by OWNER
        campaign.finalizeRequest(0);
        vm.expectRevert(Campaign.Campaign__RequestWasAlreadyFinalized.selector); // the next line should revert, it should fail as OWNER is trying to finalize the same request again
        campaign.finalizeRequest(0);
        vm.stopPrank();
    }

    function testToCheckIfREquestRecievedFiftyPercentOfApprovals()
        public
        createRequest
    {
        vm.prank(CONTRIBUTOR_TWO); // The next TX will be send by CONTRIBUTOR_TWO
        campaign.contribute{value: 2 ether}();
        vm.prank(CONTRIBUTOR_THREE); // The next TX will be send by CONTRIBUTOR_THREE
        campaign.contribute{value: 2 ether}();
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        campaign.approveRequest(0);
        vm.prank(OWNER); // The next TX will be send by OWNER
        vm.expectRevert(
            Campaign
                .Campaign__RequestCanNotBeFinalizedAsNotEnoughApprovers
                .selector
        ); // the next line should revert, it should fail as request has 1 approval out of 3
        campaign.finalizeRequest(0);
    }

    function testIfRequestIsMarkedAsFinalizedOnceFinalized()
        public
        createRequest
    {
        vm.startPrank(CONTRIBUTOR); // The next transactions will be send by CONTRIBUTOR
        campaign.approveRequest(0);
        vm.stopPrank();
        vm.prank(OWNER); // The next TX will be send by OWNER
        campaign.finalizeRequest(0);
        (, , , bool complete, ) = campaign.getRequest(0);
        assertTrue(complete);
    }

    function testCreateRequestContributeApproveRequestFinalizeRequestSendMoney()
        public
    {
        uint256 recipientStartingBalance = RECIPIENT.balance;
        uint256 AMOUNT_TO_SEND = 1 ether;
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        campaign.contribute{value: 2 ether}();
        vm.prank(OWNER); // The next TX will be send by OWNER
        campaign.createRequest("Delivery cost", AMOUNT_TO_SEND, RECIPIENT);
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR
        campaign.approveRequest(0);
        vm.prank(OWNER); // The next TX will be send by OWNER
        campaign.finalizeRequest(0);
        uint256 recipientEndingBalance = RECIPIENT.balance;
        assertEq(
            recipientEndingBalance,
            recipientStartingBalance + AMOUNT_TO_SEND
        );
    }

    function testCreateRequestContributeApproveRequestFinalizeRequestRevertSendMoneyAsContractDoesNotHaveEnoughBalance()
        public
    {
        uint256 AMOUNT_TO_SEND_DELIVERY_ONE = 3 ether;
        uint256 AMOUNT_TO_SEND_DELIVERY_TWO = 2 ether;
        vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR donating 4 ETH
        campaign.contribute{value: 4 ether}();

        vm.startPrank(OWNER); // The next TX will be send by OWNER, at this moment contract has 4 ETH donated by CONTRIBUTOR above
        campaign.createRequest(
            "Delivery One cost",
            AMOUNT_TO_SEND_DELIVERY_ONE,
            RECIPIENT
        );
        campaign.createRequest(
            "Delivery Two cost",
            AMOUNT_TO_SEND_DELIVERY_TWO,
            RECIPIENT
        );
        vm.stopPrank();
        vm.startPrank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR, he will approve both requests
        campaign.approveRequest(0);
        campaign.approveRequest(1);
        vm.startPrank(OWNER); // The next TX will be send by OWNER, finalizing first request for 3 ETH and then finalizing second request for 2 ETH which should fail as contract will have 1 ETH left -> 4 - 3 = 1 ETH
        campaign.finalizeRequest(0);
        vm.expectRevert(
            Campaign
                .Campaign__RequestCanNotBeFinalizedAsContractDoesNotHaveEnoughBalance
                .selector
        );
        campaign.finalizeRequest(1);
        vm.stopPrank();
    }

    // function testCreateRequestWithEmptyDescription() public {
    //     // Attempt to create a request with an empty description
    //     vm.prank(CONTRIBUTOR); // The next TX will be send by CONTRIBUTOR donating 4 ETH
    //     campaign.contribute{value: 4 ether}();
    //     vm.prank(OWNER); // The next TX will be sent by OWNER
    //     campaign.createRequest("", 1 ether, RECIPIENT); // Empty description
    // }
}

// /*
// 1. Unit: Testing a single function
// 2. Integration: Testing multiple functions
// 3. Forked: Testing on a forked network
// 4. Staging: Testing on a live network (testnet or mainnet)
// */
