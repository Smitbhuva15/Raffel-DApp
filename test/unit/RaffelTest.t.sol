// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffel} from "../../script/DeployRaffel.s.sol";
import {Raffel} from "../../src/Raffel.sol";
import {HelpingConfig} from "../../script/HelpingConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {Vm} from "forge-std/Vm.sol";

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

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffel.performUpkeep("");

        vm.prank(PLAYER);
        vm.expectRevert(Raffel.Raffle__RaffleNotOpen.selector);
        raffel.RaffelFun{value: entranceFee}();
    }

    // ////////////////////////   CHECKUPKEEP       ///////////////////////////////

    function testCheckUpkeepReturnsFalseIfItHasNoBalance() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded, ) = raffel.checkUpkeep("");

        assert(upkeepNeeded == false);
    }

    function testCheckUpkeepReturnsFalseIfRaffleIsntOpen() public {
        vm.prank(PLAYER);
        raffel.RaffelFun{value: entranceFee}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffel.performUpkeep("");
        (bool upkeepNeeded, ) = raffel.checkUpkeep("");

        assert(upkeepNeeded == false);
    }

    function testCheckUpkeepReturnsFalseIfEnoughTimeHasntPassed() public {
        vm.prank(PLAYER);
        raffel.RaffelFun{value: entranceFee}();

        (bool upkeepNeeded, ) = raffel.checkUpkeep("");

        assert(upkeepNeeded == false);
    }

    function testCheckUpkeepReturnsTrueWhenParametersGood() public {
        vm.prank(PLAYER);
        raffel.RaffelFun{value: entranceFee}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded, ) = raffel.checkUpkeep("");

        assert(upkeepNeeded == true);
    }

    ////////////////////////////////////////////         PERFORMUPKEEP           //////////////////////////////////////

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public {
        vm.prank(PLAYER);
        raffel.RaffelFun{value: entranceFee}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffel.performUpkeep("");
    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        uint256 rState = 0;

        vm.expectRevert(
            abi.encodeWithSelector(
                Raffel.Raffle__UpkeepNotNeeded.selector,
                currentBalance,
                numPlayers,
                rState
            )
        );
        raffel.performUpkeep("");
    }

    modifier raffleEntered() {
        vm.prank(PLAYER);
        raffel.RaffelFun{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public raffleEntered {
        vm.recordLogs();
        raffel.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        Raffel.RaffleState raffleState = raffel.getRaffelState();

        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1);
    }



    //////////////////////////////////            FulfillRandomWords       /////////////////////////////////////


    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(
        uint256 randomNumberId
    ) public raffleEntered {
        vm.expectRevert();
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            randomNumberId,
            address(raffel)
        );
    }

    function testFulfillRandomWordsPicksAWinnerResetsAndSendsMoney()
        public
        raffleEntered
    {
        uint256 additionalEntrances = 3;
        uint256 startingIndex = 1;

        for (
            uint256 i = startingIndex;
            i < startingIndex + additionalEntrances;
            i++
        ) {
            address player = address(uint160(i));
            hoax(player, 1 ether);
            raffel.RaffelFun{value: entranceFee}();
        }

        uint256 startingTimeStamp = raffel.getLastTimeStamp();
        uint startingBalance = address(1).balance;

        vm.recordLogs();
        raffel.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId),
            address(raffel)
        );

        uint256 endingTimeStamp = raffel.getLastTimeStamp();
        uint256 prize = entranceFee * (additionalEntrances + 1);
        console.log(entranceFee);
        console.log(prize);

        assert(uint256(raffel.getRaffelState()) == 0);
        assert(raffel.getNumberOfPlayers() == 0);
      
        assert(
            raffel.getRecentWinner().balance ==
                (prize + startingBalance )

                
        );
        assert(endingTimeStamp > startingTimeStamp);
    }
}
