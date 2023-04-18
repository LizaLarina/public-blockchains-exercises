// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Lock4 {
    uint256 public immutable blockNumber;
    uint256 public ownerCounter;
    uint8 constant CAN_WITHDRAW = 1;
    uint8 constant HAS_WITHDRAWN = 2;

    mapping(address => uint8) public owners;


    event Withdrawal(uint amount, uint when);
    event WithdrawalAttempt(uint amount, uint when, address fromWho);

    constructor() payable {
        blockNumber = block.number;
        owners[msg.sender] = 1;
        ownerCounter = 1;
    }

    function addOwner(address newOwner) public returns (bool) {
        newOwner = payable(newOwner);
        // Already inited.
        if (owners[newOwner] > 0) {
            return false;
        }
        // New owner.
        owners[newOwner] = CAN_WITHDRAW;
        ownerCounter += 1;
        return true;
    }

    function withdraw() public {

        console.log("LOG>", owners[msg.sender]);

        emit WithdrawalAttempt(address(this).balance, block.timestamp, msg.sender);

        require(owners[msg.sender] > 0, "You are not one of the owners");
        require(owners[msg.sender] == 1, "You have already withdrawn");

        // require(block.timestamp >= unlockTime, "You can't withdraw yet");

        emit Withdrawal(address(this).balance, block.timestamp);


        // Compute amount and send it.
        uint256 amount = address(this).balance / ownerCounter;
        payable(msg.sender).transfer(amount);

        // Update stats.
        owners[msg.sender] = HAS_WITHDRAWN;
        ownerCounter -= 1;
    }
}

