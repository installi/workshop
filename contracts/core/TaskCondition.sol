// SPDX-License-Identifier: SimPL-2.0

pragma solidity ^0.7.0;

import "../authority/Member.sol";
import "../library/Libraries.sol";

contract TaskCondition is Member {
    struct ConditionStruct {
        uint256 condition_id;
        uint256 party_a;
        uint256 party_b;
        uint256 condition;
        Operator operator;
    }

    enum Operator {GREATER, LESS, EQUAL}

    mapping (uint256 => ConditionStruct) _deft;
    mapping (uint256 => mapping (uint256 => ConditionStruct)) _conditions;

    constructor(address auth_) Member(auth_) {
        
    }

    function create(
        uint256 task_id_,
        uint256 condition_id_,
        uint256 party_a_,
        uint256 party_b_,
        uint256 condition_,
        Operator operator_
    ) public CheckPermit("Task") {
        ConditionStruct memory cs = ConditionStruct({
            condition_id: condition_id_,
            party_a: party_a_,
            party_b: party_b_,
            condition: condition_,
            operator: operator_
        });

        _conditions[task_id_][condition_id_] = cs;
    }

    function validate(
        uint256 value,
        uint256 task_id_,
        uint256 condition_id_
    ) public view returns (bool) {
        
        return true;
    }
}