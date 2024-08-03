// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 constant SEND_VALUE = 0.1 ether;
    address USER = makeAddr("User");
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testIsOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testDataFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundWithoutValueFails() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundWorks() public {
        fundMe.fund{value: SEND_VALUE}();
        assertEq(SEND_VALUE, address(fundMe).balance);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFunderAdded() public funded {
        console.log(USER);
        // console.log(fundMe.funders(0));
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawAllWithMultipleFunders() public {
        uint160 AMOUNT_ADDRESES = 10;
        uint160 STARTING_ADDRESS = 1;

        for (uint160 i = STARTING_ADDRESS; i <= AMOUNT_ADDRESES; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        address OWNER = fundMe.getOwner();

        uint256 STARTING_BALANCE_OWNER = address(OWNER).balance;
        uint256 STARTING_BALANCE_CONTRACT = address(fundMe).balance;

        vm.startPrank(OWNER);
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(
            address(OWNER).balance,
            STARTING_BALANCE_OWNER + STARTING_BALANCE_CONTRACT
        );
    }
}
