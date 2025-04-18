// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {HelpingConfig} from "./HelpingConfig.s.sol";

import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";


contract CreateSubScription is Script {
    function CreateSubScriptionId(
        address vrfCoordinator
    ) public returns (uint64) {
        vm.startBroadcast();
        uint64 SubScriptionId = VRFCoordinatorV2Mock(vrfCoordinator)
            .createSubscription();
        console.log(SubScriptionId, "///////");
        vm.stopBroadcast();

        return SubScriptionId;
    }

    function handelSubscriptionId() public returns (uint64) {
        HelpingConfig helperConfig = new HelpingConfig();
        (, , address vrfCoordinator, , , , ) = helperConfig
            .localNetworkConfig();

        return CreateSubScriptionId(vrfCoordinator);
    }

    function run() external returns (uint64) {
        return handelSubscriptionId();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscription(
        address vrfCoordinator,
        uint64 subscriptionId,
        address link
    ) public {
        console.log("Funding subscription: ", subscriptionId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else{
             console.log(LinkToken(link).balanceOf(msg.sender));
            console.log(msg.sender);
            console.log(LinkToken(link).balanceOf(address(this)));
            console.log(address(this));
            vm.startBroadcast();
            LinkToken(link).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
            vm.stopBroadcast();
        }
    }

    function fundSubscriptionUsingConfig() public {
        HelpingConfig helperConfig = new HelpingConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint64 subscriptionId,
            ,
            address link
        ) = helperConfig.localNetworkConfig();

        fundSubscription(vrfCoordinator, subscriptionId, link);
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    
    function addConsumer(
        address contractToAddToVrf,
        address vrfCoordinator,
        uint64 subscriptionId
    ) public {
        console.log("Adding consumer contract: ", contractToAddToVrf);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);

        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(
            subscriptionId,
            contractToAddToVrf
        );
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelpingConfig helperConfig = new HelpingConfig();
        (, , address vrfCoordinator, , uint64 subscriptionId, , ) = helperConfig
            .localNetworkConfig();
        addConsumer(mostRecentlyDeployed, vrfCoordinator, subscriptionId);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}
