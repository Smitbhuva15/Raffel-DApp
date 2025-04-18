// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {Script,console} from "forge-std/Script.sol";
import {HelpingConfig} from "./HelpingConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubScription is Script {

    function CreateSubScriptionId(
        address vrfCoordinator
    ) public returns (uint64) {
        vm.startBroadcast();
        uint64 SubScriptionId = VRFCoordinatorV2Mock(vrfCoordinator)
            .createSubscription();
            console.log(SubScriptionId,"///////");
        vm.stopBroadcast();

        return SubScriptionId;
    }

    function handelSubscriptionId() public returns (uint64) {
        HelpingConfig helperConfig = new HelpingConfig();
        (, , address vrfCoordinator, , , ,) = helperConfig.localNetworkConfig();

        return CreateSubScriptionId(vrfCoordinator);
    }

    function run() external returns (uint64) {
        return handelSubscriptionId();
    }
}
