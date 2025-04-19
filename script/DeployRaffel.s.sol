// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script,console} from "forge-std/Script.sol";
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
            address link,
            uint256 deployerKey
        ) = helperConfig.localNetworkConfig();

        

        if (subscriptionId == 0) {
            CreateSubScription createsubscription = new CreateSubScription();
            subscriptionId = createsubscription.CreateSubScriptionId(
                vrfCoordinator,
                deployerKey
            );

            //  fund it
            FundSubscription fundSub = new FundSubscription();
            fundSub.fundSubscription(vrfCoordinator, subscriptionId, link,deployerKey);
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
      addconsumer.addConsumer(address(r1),vrfCoordinator,subscriptionId,deployerKey);

        return (r1, helperConfig);
    }
}
