// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffel} from "../src/Raffel.sol";
import {HelpingConfig} from "./HelpingConfig.s.sol";
import {CreateSubScription}  from './Interactions.s.sol';

contract DeployRaffel is Script {
    function run() external returns (Raffel,HelpingConfig) {
        HelpingConfig helperConfig = new HelpingConfig();
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit
        ) = helperConfig.localNetworkConfig();

       if(subscriptionId==0){
        CreateSubScription createsubscription=new CreateSubScription();
        subscriptionId=createsubscription.CreateSubScriptionId(vrfCoordinator);
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

        return (r1,helperConfig);
    }
}
