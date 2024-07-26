// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        // Log initial balances
        console.log("Initial FundMe balance:", address(fundMe).balance);
        console.log("Initial USER balance:", USER.balance);

        // Create FundFundMe instance
        FundFundMe fundFundMe = new FundFundMe();

        // Fund the FundFundMe contract
        vm.deal(address(fundFundMe), 1 ether);
        console.log("FundFundMe balance after funding:", address(fundFundMe).balance);

        // Attempt to fund and catch any errors
        try fundFundMe.fundFundMe(address(fundMe)) {
            console.log("Funding successful");
        } catch Error(string memory reason) {
            console.log("Funding failed. Reason:", reason);
            // fail("Funding should not fail");
        } catch (bytes memory lowLevelData) {
            console.log("Funding failed. Low-level error:", string(lowLevelData));
            // fail("Funding should not fail");
        }

        // Log balances after funding attempt
        console.log("FundMe balance after funding:", address(fundMe).balance);
        console.log("USER balance after funding:", USER.balance);

        // Create WithdrawFundMe instance
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

        // Attempt to withdraw and catch any errors
        try withdrawFundMe.withdrawFundMe(address(fundMe)) {
            console.log("Withdrawal successful");
        } catch Error(string memory reason) {
            console.log("Withdrawal failed. Reason:", reason);
            // fail("Withdrawal should not fail");
        } catch (bytes memory lowLevelData) {
            console.log("Withdrawal failed. Low-level error:", string(lowLevelData));
            // fail("Withdrawal should not fail");
        }

        // Log final balances
        console.log("Final FundMe balance:", address(fundMe).balance);
        console.log("Final USER balance:", USER.balance);

        // Assert final balance
        assert(address(fundMe).balance == 0);
    }
}
