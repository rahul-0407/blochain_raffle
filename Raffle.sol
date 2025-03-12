//SPDX-License-Identifier: MIT

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

/**
 *  @title A Sample raffle contracy
 *  @author Rahul Gupta
 *  @notice This contract is for creating sample raffle contract
 *  @dev  Implements chainlink VRFv2.5
 */

contract Raffle{
    // Errors
    error Raffle__SendMoreToEnterRaffle();

    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    constructor(uint256 entranceFee){
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public {
        // require(msg.value>=i_entranceFee,"Not enough eth")
        // require(msg.value >= i_entranceFee, SendMoreToEnterRaffle());
        if(msg.value < i_entranceFee){
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
        
    }

    function pickWinner() public {}

    /**Getter function */
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }

}