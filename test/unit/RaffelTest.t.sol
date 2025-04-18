// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffel} from "../../script/DeployRaffel.s.sol";
import {Raffel} from "../../src/Raffel.sol";
import {HelpingConfig} from "../../script/HelpingConfig.s.sol";

contract RaffelTest is Test {
    event EnteredRaffel(address indexed player);

    Raffel raffel;
    HelpingConfig helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;

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
            callbackGasLimit,
            link
        ) = helperConfig.localNetworkConfig();

        vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffel.getRaffelState() == Raffel.RaffleState.OPEN);
    }

    function testforenteredvalue() public {
        vm.prank(PLAYER);

        vm.expectRevert(Raffel.Raffle__SendMoreToEnterRaffle.selector);
        raffel.RaffelFun();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(PLAYER);

        raffel.RaffelFun{value: entranceFee}();
        address firstEnteres = raffel.getPlayerWithIndex(0);
        vm.assertEq(firstEnteres, PLAYER);
    }

    function testEmitsEventOnEntrance() public {
        vm.prank(PLAYER);

        vm.expectEmit(true, false, false, false);
        emit EnteredRaffel(PLAYER);
        raffel.RaffelFun{value: entranceFee}();
    }

    function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
        vm.prank(PLAYER);
        raffel.RaffelFun{value: entranceFee}();

       vm.warp(block.timestamp + interval+ 1);
        vm.roll(block.number + 1);
        raffel.performUpkeep("");

        vm.prank(PLAYER);
        vm.expectRevert(Raffel.Raffle__RaffleNotOpen.selector);
        raffel.RaffelFun{value: entranceFee}();
    }
}
