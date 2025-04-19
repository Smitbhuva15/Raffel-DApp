// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffel} from "../src/Raffel.sol";
import {HelpingConfig} from "./HelpingConfig.s.sol";
import {CreateSubScription, FundSubscription, AddConsumer} from "./Interactions.s.sol";


contract DeployRaffel is Script {
    function run() external returns (Raffel, HelpingConfig) {
        HelpingConfig helperConfig = new HelpingConfig();
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link
        ) = helperConfig.localNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubScription createsubscription = new CreateSubScription();
            subscriptionId = createsubscription.CreateSubScriptionId(
                vrfCoordinator
            );

            //  fund it
            FundSubscription fundSub = new FundSubscription();
            fundSub.fundSubscription(vrfCoordinator, subscriptionId, link);
        }

        vm.startBroadcast();
        Raffel r1 = new Raffel(
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();
      AddConsumer addconsumer=new AddConsumer();
      addconsumer.addConsumer(address(r1),vrfCoordinator,subscriptionId);

        return (r1, helperConfig);
    }
}
