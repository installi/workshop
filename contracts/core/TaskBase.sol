// SPDX-License-Identifier: SimPL-2.0

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../authority/Member.sol";
import "../library/Libraries.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TaskBase is Member, ERC20 {
    using SafeMath for uint256;

    uint256 private _fee_rate = 3;
    address payable private _fee_recipient;

    constructor(address auth_) Member(auth_)
        ERC20("Task Token", "WTK") {

        _fee_recipient = msg.sender;
    }

    function create(
        uint256 delivery_date_,
        uint256[][] memory conditions_
    ) payable external returns (uint256 task_id) {
        require(
            msg.value > 0,
            "Task: Commission is invalid"
        );

        require(
            delivery_date_ > block.timestamp,
            "Task: Delivery date is invalid."
        );

        
    }
}