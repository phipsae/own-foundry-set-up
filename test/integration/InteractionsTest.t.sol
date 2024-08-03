// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    uint256 constant SEND_VALUE = 0.1 ether;
    address OWNER = makeAddr("Owner");
    address USER = makeAddr("User");
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        // vm.startPrank(OWNER);
        fundMe = deployFundMe.run();
        // vm.stopPrank();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundAndOwnerCanWithdraw() public {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
        fundMe.withdraw();
        vm.stopPrank();

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
