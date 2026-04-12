//SPDX-License-Identifier-MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utilis/ReentrancyGuards.sol";//prevents reentrancy attacks,before state updates,calls again

contract Crowdfunding is ReentrancyGuards {

    struct Campaign {
        address creator;
        uint goal; //targeted ETH
        uint pledged; //collected ETH
        uint deadline;
        bool claimed;
    }

    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    uint public campaignCount;//auto increment ID  for campaigns

    //Events
    event CampaignCreated(uint id, address creator, uint goal, uint deadline);
    event Funded(uint id, address contributor, uint amount);
    event Withdrawn(uint id);
    event Refunded(uint id, address contributor, uint amount);

    function createCampaign(uint _goal, uint _duration) external {
       campaignCount++;

       campaigns[campaignCount] = Campaign({
        creator: msg.sender,
        goal:_goal,
        pledged:0,
        deadline: block.timestamp + _duration,
        claimed: false
       });

       emit CampaignCreated(campaignCount, msg.sender, _goal, block.timestamp + _duration);
    }

    function fundCampaign(uint _id) external payable {
        Campaign storage campaign = campaign[_id];

        require(block.timestamp , campaign.deadline, "Campaign ended");

        campaign.pledged += msg.value;
        pledgedAmount[_id][msg.sender] += msg.value;

        emit funded(_id, msg.sender, msg.value);
    }

    function withdrawFunds(uint _id) external nonReentrant {
        Campaign storage campaign = campaign[_id];

        require(msg.sender == campiagn.creator, "Not creator");
        require(bloack.timestamp >= campaign.deadline, "Still running");
        require(campaign.pledged >= campaign.goal,"goal not met");
        require(!campaign.claimed,"Already claimed");

        campaign.claimed = true;
        payable(campaign.creator).transfer(campaign.pledged);
        emit Withdrawn(_id);
    }
   
    function refund(uint _id) external nonReentrant {
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp >= campaign.deadline, "Still running");
        require(campaign.pledged < campaign.goal, "goal met");

        uint balance = pledgedAmount[_id][msg.sender];
        require(balance > 0, "No funds");

        pledgedAmount[_id][msg.sender] = 0;

        payable(msg.sender).transfer(balance);

        emit Refunded(_id, msg.sender, balance);

    }

}