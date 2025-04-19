// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {HelpingConfig} from "./HelpingConfig.s.sol";

import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract CreateSubScription is Script {
    function CreateSubScriptionId(
        address vrfCoordinator,
        uint256 deployerKey
    ) public returns (uint64) {
        vm.startBroadcast(deployerKey);
        uint64 SubScriptionId = VRFCoordinatorV2Mock(vrfCoordinator)
            .createSubscription();
        console.log(SubScriptionId, "///////");
        vm.stopBroadcast();

        return SubScriptionId;
    }

    function handelSubscriptionId() public returns (uint64) {
        HelpingConfig helperConfig = new HelpingConfig();
        (, , address vrfCoordinator, , , , , uint256 deployerKey) = helperConfig
            .localNetworkConfig();

        return CreateSubScriptionId(vrfCoordinator, deployerKey);
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
        address link,
        uint256 deployerKey
    ) public {
        console.log("Funding subscription: ", subscriptionId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            console.log(LinkToken(link).balanceOf(msg.sender));
            console.log(msg.sender);
            console.log(LinkToken(link).balanceOf(address(this)));
            console.log(address(this));
            vm.startBroadcast(deployerKey);
            LinkToken(link).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
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
            address link,
            uint256 deployerKey
        ) = helperConfig.localNetworkConfig();

        fundSubscription(vrfCoordinator, subscriptionId, link, deployerKey);
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(
        address contractToAddToVrf,
        address vrfCoordinator,
        uint64 subscriptionId,
        uint256 deployerKey
    ) public {
        console.log("Adding consumer contract: ", contractToAddToVrf);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
     

        if (block.chainid == 31337) {
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(
                subscriptionId,
                contractToAddToVrf
            );
            vm.stopBroadcast();
        } else {
            console.log(vm.addr(deployerKey),"deployerKey");
            console.log( vm.addr(vm.envUint("PRIVATE_KEY")));
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Interface(vrfCoordinator).addConsumer(
                subscriptionId,
                contractToAddToVrf
            );

            vm.stopBroadcast();
        }
    }

    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelpingConfig helperConfig = new HelpingConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint64 subscriptionId,
            ,
            ,
            uint256 deployerKey
        ) = helperConfig.localNetworkConfig();
        addConsumer(
            mostRecentlyDeployed,
            vrfCoordinator,
            subscriptionId,
            deployerKey
        );
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Raffel",
            block.chainid
        );
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}
