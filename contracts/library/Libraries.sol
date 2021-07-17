// SPDX-License-Identifier: SimPL-2.0

pragma solidity ^0.7.0;

library TaskLibrary {
    struct TaskStruct {
        uint256 task_id;
        uint256 commission;
        uint256 delivery_date;
        address payable employer;
    }

    event Create(
        uint256 taskId,
        uint256 commission,
        uint256 delivery
    );

    event Acceptance(
        uint256 taskId,
        uint256 fee,
        uint256 commission
    );

    enum TaskStatus {
        INVALID,
        WORKING,
        DONE
    }
}

library ConditionLibrary {
    struct ConditionStruct {
        string name;
        uint256 party_a;
        uint256 party_b;
        uint256 condition;
        Operator operator;
    }

    enum Operator {
        GREATER,
        LESS,
        EQUAL
    }

    function validate(
        uint256 value,
        uint256 condition,
        Operator operator
    ) public pure returns (bool) {
        if (operator == Operator.GREATER) {
            return value > condition;
        }

        if (operator == Operator.LESS) {
            return value < condition;
        }

        if (operator == Operator.GREATER) {
            return value == condition;
        }

        return false;
    }
}