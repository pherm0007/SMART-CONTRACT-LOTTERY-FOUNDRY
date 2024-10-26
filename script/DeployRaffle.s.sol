// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {CreateSubScription, FundSubScription, AddConsumer} from "script/Interactions.s.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

contract DeployRaffle is Script {
    function run() public {}

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            CreateSubScription createSubScription = new CreateSubScription();
            (config.subscriptionId, config.vrfCoordinator) = createSubScription
                .createSubscription(config.vrfCoordinator, config.account);
        }
        FundSubScription fundSubscription = new FundSubScription();
        fundSubscription.fundSubscription(
            config.vrfCoordinator,
            config.subscriptionId,
            config.link,
            config.account
        );

        vm.startBroadcast(config.account);

        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );

        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            config.vrfCoordinator,
            config.subscriptionId,
            config.account
        );

        return (raffle, helperConfig);
    }
}
