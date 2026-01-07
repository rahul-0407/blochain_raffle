// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {CodeConstants} from "script/HelperConfig.s.sol";

contract RaffleTest is CodeConstants, Test{
    event RaffleEntered(address indexed player);


    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 constant STARTING_VALUE = 10 ether;
    uint256 public constant LINK_BALANCE = 100 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployRaffle();
        vm.deal(PLAYER,STARTING_VALUE);

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;
    }

    function testRaffleInitializesInOpenState() public view{
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWHenYouDontPayEnough() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
    }


    function testRaffleRecordsPlayerWhenTheyEnter() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        raffle.enterRaffle{value: entranceFee}();
        // Assert
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEnteringRaffleEmitsEvent() public {
        vm.prank(PLAYER);

        vm.expectEmit(true,false,false,false, address(raffle));
        emit RaffleEntered(PLAYER);

        raffle.enterRaffle{value:entranceFee}();
    }

    function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public{
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value:entranceFee}();
        vm.warp(block.timestamp + interval +1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        //Act //assert
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value:entranceFee}();
    }

    function testCheckUpKeepReturnsFalseIfItHasNoBalance() public{
        //Arrange
        vm.warp(block.timestamp + interval +1);
        vm.roll(block.number + 1);

        //Act
        (bool upKeepNeeded, ) = raffle.checkUpKeep("");

        //assert
        assert(!upKeepNeeded);
    }
    
    function testCheckUpKeepReturnFalseIfRaffleIsntOpen() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value:entranceFee}();
        vm.warp(block.timestamp + interval +1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        //Act
        (bool upKeepNeeded, ) = raffle.checkUpKeep("");

        //Assert 
        assert(!upKeepNeeded);
    }

      //challege
    //testCheckUpKeepReturnsFalseIfEnoughTimeHasPassed
    //testChecckUpKeepReturnsTRueWhenParametersAreGood






    function testPerformUpKeepCanOnlyRunIfCheckUpKeepIsTrue() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value:entranceFee}();
        vm.warp(block.timestamp + interval +1);
        vm.roll(block.number + 1);

        //Act /Assert
        raffle.performUpkeep("");
    }

    function testPerformUpKeepRevertsIfCheckUpKeepIsFalse() public{
        //Arrange
        uint256 currentBalance  = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState rState = raffle.getRaffleState();

        vm.prank(PLAYER);
        raffle.enterRaffle{value:entranceFee}();
        currentBalance = currentBalance + entranceFee;
        numPlayers = 1;

        //Act //assert
        vm.expectRevert(
            abi.encodeWithSelector(Raffle.Raffle__UpKeepNotNeeded.selector,currentBalance,numPlayers,rState)
        );
        raffle.performUpkeep("");
    }

    modifier raffleEntered() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpKeepUpdateRaffleStateAndEmitsRequestId() public raffleEntered{
       

        //Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        //Assert
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1);
    }


    modifier  skipFork() {
        if(block.chainid != LOCAL_CHAIN_ID){
            return;
        }
        _;
    }

    function testFullfillrandomWordsCanOnlyBeCalledAfterPerformUpKeep(uint256 randomRequestId) public raffleEntered skipFork {
        
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(raffle));

    }

  
    function testFullfillRandomWordsPicksAWinnerResetsAndSendsMoney() public raffleEntered skipFork {
        uint256 additionalEntrants = 3;
        uint256 startingIndex = 1;
        address expectedWinner = address(1);

        for(uint256 i = startingIndex; i< startingIndex + additionalEntrants; i++){
            address newPlayer = address(uint160(i));
            hoax(newPlayer, 1 ether);
            raffle.enterRaffle{value:entranceFee}();
        }
        uint256 startingTimeStamp = raffle.getLatTimeStamp();
        uint256 winnerStartingBalance = expectedWinner.balance;
        
        //Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(raffle));

        //Assert
        address recentWinner = raffle.getRecentWinner();
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        uint256 winnnerBalance = recentWinner.balance;
        uint256 endingTimestamp = raffle.getLatTimeStamp();
        uint256 prize = entranceFee * (additionalEntrants + 1);

        assert(recentWinner == expectedWinner);
        assert(uint256(raffleState)==0);
        assert(winnnerBalance == winnerStartingBalance + prize);
        assert(endingTimestamp > startingTimeStamp);

    }



    
}