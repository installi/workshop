// SPDX-License-Identifier: SimPL-2.0

pragma solidity ^0.7.0;

import "../authority/Member.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Task is Member, ERC20 {
    using SafeMath for uint256;

    struct TaskStruct {
        address payable party_a;
        address payable party_b;
        uint256 sign_a;
        uint256 sign_b;
        uint256 task_id;
        uint256 amount;
        uint256 status;
        uint256 delivery_date;
        uint256[] acceptance_conditions;
    }

    TaskStruct[] private _task;
    uint256 private _fee_rate;
    address payable private _fee_recipient;

    mapping (uint256 => string) private _works;
    mapping (address => mapping (uint256 => uint256[])) _score;

    event Create(uint256 amount, uint256 date, uint256 taskId);
    event Acceptance(uint256 taskId, uint256 fee, uint256 amount);

    constructor(
        address auth_,
        uint256 fee_rate_,
        address payable recipient_
    ) Member(auth_) ERC20("Task Token", "WTK") {
        require(
            fee_rate_ > 0,
            "Task: The fee rate must greater than zero"
        );

        _fee_rate = fee_rate_;
        _fee_recipient = recipient_;
    }

    function _sign(uint256 party_, uint256 task_id_)
        private {

        if (party_ == 1) {
            require(
                _task[task_id_].sign_a == 0,
                "Task: The contract has been signed"
            );
            _task[task_id_].sign_a = block.timestamp;
        } else {
            require(
                _task[task_id_].sign_b == 0,
                "Task: The contract has been signed"
            );
            _task[task_id_].party_b = msg.sender;
            _task[task_id_].sign_b = block.timestamp;
        }

        bool is_a = _task[task_id_].sign_a == 0;
        bool is_b = _task[task_id_].sign_b == 0;

        if (is_a || is_b) { return; }
        _task[task_id_].status = 2;
    }

    function _calc(uint256 task_id_) private {
        uint256 fee = _task[task_id_].amount.mul(_fee_rate);
        uint256 realAmount = _task[task_id_].amount.sub(fee);

        _task[task_id_].status = 10;
        _task[task_id_].party_b.transfer(realAmount);
        _fee_recipient.transfer(fee);

        emit Acceptance(task_id_, fee, realAmount);
    }

    function setFeeRate(uint256 fee_rate_) external
        CheckPermit("Config") {

        require(
            fee_rate_ > 0,
            "Task: The fee rate must greater than zero"
        );

        _fee_rate = fee_rate_;
    }

    function create(
        uint256 delivery_date_,
        uint256[] memory acceptance_conditions
    ) payable external returns (uint256 taskId) {
        require(
            msg.value > 0,
            "Task: Task reward must greater than zero"
        );

        require(
            delivery_date_ > block.timestamp,
            "Task: Delivery date is invalid."
        );

        bytes memory seed = abi.encodePacked(block.timestamp);
        taskId = uint256(keccak256(seed));

        for (uint256 i = 0; i < acceptance_conditions.length; i++) {

        }

        _task.push(TaskStruct ({
            party_a: msg.sender,
            party_b: address(0),
            sign_a: 0,
            sign_b: 0,
            task_id: taskId,
            amount: msg.value,
            status: 1,
            delivery_date: delivery_date_,
            acceptance_conditions: acceptance_conditions
        }));

        _mint(msg.sender, msg.value);

        emit Create(msg.value, delivery_date_, taskId);
    }

    function cancel(uint256 task_id_) external {
        require(
            msg.sender == _task[task_id_].party_a,
            "Task: Only owner"
        );

        require(
            _task[task_id_].status == 1,
            "Task: Can not cancel this task"
        );

        msg.sender.transfer(_task[task_id_].amount);
        _burn(msg.sender, _task[task_id_].amount);

        _task[task_id_].status = 0;
    }

    function signPartyA(uint256 task_id_) external {
        _sign(1, task_id_);
    }

    function signPartyB(uint256 task_id_) external {
        _sign(2, task_id_);
    }

    function deliver(string memory url, uint256 task_id_)
        external {

        require(
            msg.sender == _task[task_id_].party_b,
            "Task: This operation is not allowed"
        );

        require(
            _task[task_id_].status != 2 ||
            _task[task_id_].status != 1 ||
            _task[task_id_].status != 0,
            "Task: The two sides haven't signed yet"
        );

        _task[task_id_].status = 3;
        _works[task_id_] = url;
    }

    function getWorks(address party_a_, uint256 task_id_)
        public view returns (string memory) {

        require(
            party_a_ == _task[task_id_].party_a,
            "Task: This operation is not allowed"
        );

        return _works[task_id_];
    }

    function acceptance(
        uint256 task_id_,
        uint256[5] memory score_
    ) external {
        require(
            msg.sender == _task[task_id_].party_a,
            "Task: This operation is not allowed"
        );

        require(
            _task[task_id_].status == 3,
            "Task: No work has been submitted"
        );

        _score[_task[task_id_].party_b][task_id_] = score_;
        _calc(task_id_);
    }

    function getCommission(
        uint256 task_id_,
        uint256[5] memory score_
    ) external {
        require(
            msg.sender == _task[task_id_].party_b,
            "Task: This operation is not allowed"
        );

        require(
            _task[task_id_].status == 10 ||
            block.timestamp >= _task[task_id_].delivery_date,
            "Task: Party A has not accepted yet"
        );

        _score[_task[task_id_].party_a][task_id_] = score_;
        _calc(task_id_);
    }
}