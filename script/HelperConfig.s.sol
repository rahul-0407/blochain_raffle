// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

abstract contract CodeConstants {
    /* VRF MOCK VALUES */
    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    /* LINK / ETH Price */
    int256 public MOCK_WEI_PER_UINT_LINK = 4e15;


   uint256 public constant ETH_SEPOLIA_CHAIN_ID = 1115511;
   uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script{

    error HelperConfig__InvalidChainId();


    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
    }

    NetworkConfig public localNetworkConfig;

    mapping (uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByChainId(uint256 chainId) public returns(NetworkConfig memory){
        if(networkConfigs[chainId].vrfCoordinator != address(0)){
            return networkConfigs[chainId];
        }else if(chainId == LOCAL_CHAIN_ID){
            return getOrCreateAnvilEth();
        }else{
            revert HelperConfig__InvalidChainId();
        }
    }


    function getConfig() public returns(NetworkConfig memory){
        return getConfigByChainId(block.chainid);
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entranceFee: 0.1 ether, //1e16
            interval: 30, //30sec
            vrfCoordinator:0x5C210eF41CD1a72de73bF76eC39637bB0d3d7BEE,
            gasLane: 0x9e1344a1247c8a1785d0a4681a27152bffdb43666ae5bf7d14d24a5efd44bf71,
            subscriptionId: 0,
            callbackGasLimit: 500000
        });
    }

    function getOrCreateAnvilEth() public returns(NetworkConfig memory){
        if(localNetworkConfig.vrfCoordinator != address(0)){
            return localNetworkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCordinatororMock = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UINT_LINK);
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether, //1e16
            interval: 30, //30sec
            vrfCoordinator:address(vrfCordinatororMock),
            // doesn't matter 
            gasLane: 0x9e1344a1247c8a1785d0a4681a27152bffdb43666ae5bf7d14d24a5efd44bf71,
            subscriptionId: 0,
            callbackGasLimit: 500000
        });

        return localNetworkConfig;

    }
}