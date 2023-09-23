// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// /**
//  * @title Campaign Contract
//  * @author Danijel Crepic
//  * @notice This contract is for creating a sample campaign contract where other people can contribute/donate money for campaign and make decisions when the owner of the contract wants to spend the money for business purposes
//  * @dev
//  */

contract Campaign {
    /**Errors*/
    error Campaign__NotEnoughEthSent();
    error Campaign__ApproverIsNotContributor();
    error Campaign__ApproverAlreadyVotedForThisRequest();
    error Campaign__RequestWasAlreadyFinalized();
    error Campaign__RequestCanNotBeFinalizedAsNotEnoughApprovers();
    error Campaign__ManagerDidNotCallThisFunction();
    error Campaign__ManagerCanNotApproveRequest();
    error Campaign__RequestCanNotBeFinalizedAsContractDoesNotHaveEnoughBalance();
    error Campaign__RequestCanNotBeCreatedAsContractDoesNotHaveEnoughBalanceForRequestValue();
    error Campaign__FunctionCalledWithInvalidParameters(); // custom error for tests regarding function calls

    /**Type declarations*/
    // Request that manager can make to ask approvers to spend certain amount of money for business purposes
    struct Request {
        string requestDescription; // purpose of request
        uint256 requestValue; // ETH to transfer
        address requestRecipient; // who gets the money
        bool complete; // whether the request is approved
        uint256 approvalCount; // track number of YES approvals
        mapping(address => bool) approvals; // track who has voted
    }

    // https://ethereum.stackexchange.com/questions/87451/solidity-error-struct-containing-a-nested-mapping-cannot-be-constructed/97883#97883
    uint256 private s_numRequests; // used to track number of requests made by manager/owner
    mapping(uint256 => Request) private s_requests; // mapping of requests that the manager has created
    address private immutable i_manager; // address of the person that is managing the campaign
    uint256 private immutable i_minimumContribution; // minimum donation required to be consideres a contributor or approver
    mapping(address => bool) private s_approvers; // mapping of addresses for every person that donated money
    uint256 private s_approversCount; // every single time someone donates to our campaign, we're going to increment the value of approver count

    /**Modifiers*/
    modifier onlyManager() {
        if (msg.sender != i_manager) {
            revert Campaign__ManagerDidNotCallThisFunction();
        }
        _; // add what ever else executes in the function
    }

    /** Functions*/
    // sets the minimumContribution and the owner/manager
    constructor(uint256 minimum, address creator) {
        // manager = msg.sender; // changed to creator below as we are using CampaignFactory contract to deploy Campaign contracts
        i_manager = creator;
        i_minimumContribution = minimum;
    }

    // called when someone wants to donate money to campaign and become approver
    function contribute() public payable {
        bool alreadyContributed = s_approvers[msg.sender];
        if (!alreadyContributed) {
            if (msg.value < i_minimumContribution) {
                revert Campaign__NotEnoughEthSent();
            }
            // adding approver to mapping
            s_approvers[msg.sender] = true;
            // incrementing the variable approversCount
            s_approversCount++;
        }
    }

    // called only by manager to create a new request for spending the money
    function createRequest(
        string memory _requestDescription,
        uint256 _requestValue,
        address _requestRecipient
    ) public onlyManager {
        // checking if contract has enough funds regarding to requested value
        if (address(this).balance < _requestValue) {
            revert Campaign__RequestCanNotBeCreatedAsContractDoesNotHaveEnoughBalanceForRequestValue();
        }
        Request storage newRequest = s_requests[s_numRequests++];
        newRequest.requestDescription = _requestDescription;
        newRequest.requestValue = _requestValue;
        newRequest.requestRecipient = _requestRecipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
    }

    // called by each approver/contributor to approve spending request
    /* Requirements: 
    /* 1. make sure that the person approving request is one of the contributors
    /* 2. make sure that a single contributor cannot vote multiple times on a single spending request
    /* 3. make sure that whatever voting system we come up with, it should be resilient for if we have many different contributors or many different approvers in our campaign
    **/
    function approveRequest(uint256 requestIndex) public {
        // creating a storage variable for request that caller wants to approve
        Request storage request = s_requests[requestIndex];
        // check if request is not already marked as complete
        if (request.complete) {
            revert Campaign__RequestWasAlreadyFinalized();
        }
        if (msg.sender == i_manager) {
            revert Campaign__ManagerCanNotApproveRequest();
        }
        // checking if person that wants to approve request is also contributor(donated money to the campaign)
        if (!s_approvers[msg.sender]) {
            revert Campaign__ApproverIsNotContributor();
        }
        // checking if person that wants to approve request didn't already voted for this request
        if (request.approvals[msg.sender]) {
            revert Campaign__ApproverAlreadyVotedForThisRequest();
        }

        // if checks above pass we will add the person to approvals mappings and increase approvalCount for this request
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    // function which after a request has gotten enough approvals, the manager can call this to get money and send it to the vendor
    function finalizeRequest(uint256 requestIndex) public onlyManager {
        // creating a storage variable for request that caller wants to approve
        Request storage request = s_requests[requestIndex];
        // check if request is not already marked as complete
        if (request.complete) {
            revert Campaign__RequestWasAlreadyFinalized();
        }

        // at least 50% of all the people who have contributed to this campaign have to vote yes in order for this thing to be finalized
        if (!(request.approvalCount > (s_approversCount / 2))) {
            revert Campaign__RequestCanNotBeFinalizedAsNotEnoughApprovers();
        }

        // checking if contract has enough funds that needs to be transfered to the recipient
        if (address(this).balance < request.requestValue) {
            revert Campaign__RequestCanNotBeFinalizedAsContractDoesNotHaveEnoughBalance();
        }

        // takeing the money that is specified inside the request and attempt to send it to the recipient
        // request.requestRecipient.transfer()
        // - call -> recomended way
        (bool callSuccess /*bytes memory dataReturned*/, ) = payable(
            request.requestRecipient
        ).call{value: request.requestValue}("");
        require(callSuccess, "Call failed.");

        // mark the request as finalized
        request.complete = true;
    }

    /**Getter functions*/
    function getContractAddress() public view returns (address) {
        return address(this);
    }

    function getManager() public view returns (address) {
        return i_manager;
    }

    function getMinimumContribution() external view returns (uint256) {
        return i_minimumContribution;
    }

    function getRequest(
        uint256 _index
    ) public view returns (string memory, uint256, address, bool, uint256) {
        Request storage request = s_requests[_index];

        return (
            request.requestDescription,
            request.requestValue,
            request.requestRecipient,
            request.complete,
            request.approvalCount
        );
    }

    function getApprovalStatusOfApprover(
        uint256 _index,
        address _address
    ) public view returns (bool) {
        Request storage request = s_requests[_index];

        return request.approvals[_address];
    }

    function checkIfContributorDonatedMoney(
        address _address
    ) public view returns (bool) {
        return s_approvers[_address];
    }

    function getApproversCount() public view returns (uint256) {
        return s_approversCount;
    }

    function getSummary()
        public
        view
        returns (uint256, uint256, uint256, uint256, address)
    {
        return (
            i_minimumContribution,
            address(this).balance,
            s_numRequests,
            s_approversCount,
            i_manager
        );
    }

    function getRequestsCount() public view returns (uint256) {
        return s_numRequests;
    }
}
