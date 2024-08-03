// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    int256 public constant ETHPRICE = 2000e8;
    uint8 public constant DECIMALS = 8;

    struct Config {
        address priceFeed;
    }

    Config public activeConfig;

    constructor() {
        if (block.chainid == 1) {
            activeConfig = getMainnetConfig();
        } else if (block.chainid == 11155111) {
            activeConfig = getSepoliaConfig();
        } else {
            activeConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (Config memory) {
        return Config({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    function getMainnetConfig() public pure returns (Config memory) {
        return Config({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    }

    function getOrCreateAnvilConfig() public returns (Config memory) {
        if (activeConfig.priceFeed != address(0)) {
            return activeConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            ETHPRICE
        );
        vm.stopBroadcast();
        address mockPriceFeed = address(mockV3Aggregator);

        return Config({priceFeed: mockPriceFeed});
    }
}
