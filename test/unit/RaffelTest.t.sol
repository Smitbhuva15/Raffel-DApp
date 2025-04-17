// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffel} from "../../script/DeployRaffel.s.sol";
import {Raffel} from "../../src/Raffel.sol";
import {HelpingConfig} from "../../script/HelpingConfig.s.sol";

contract RaffelTest is Test {
    Raffel raffel;
    HelpingConfig helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffel deployer = new DeployRaffel();
        (raffel, helperConfig) = deployer.run();

        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        ) = helperConfig.localNetworkConfig();
    }

    function testRaffleInitializesInOpenState() public view{
        assert(raffel.getRaffelState()==Raffel.RaffleState.OPEN);
    }
}
