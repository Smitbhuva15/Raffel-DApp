
// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions


// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Raffel {

error Raffle__SendMoreToEnterRaffle();

    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function RaffelFun() external payable {
        if(msg.value<i_entranceFee){
             revert Raffle__SendMoreToEnterRaffle(); 
        }
    }

    /**
     * Getter Functions
     */

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}
