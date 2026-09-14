*** Settings ***
Documentation    Overdraft rules: checking accounts may go below zero up to their limit, savings accounts may not.

Resource         banking.resource

Test Tags        regression


*** Test Cases ***
Checking Account Can Be Overdrawn
    Open Funded Account    alice    20
    Withdraw Within Limit    alice    50
    Balance Should Be    alice    -30

Withdraw Exactly Up To The Limit
    Open Funded Account    alice    50
    Withdraw Within Limit    alice    150
    Balance Should Be    alice    -100

Checking Account Cannot Exceed The Limit
    Open Funded Account    alice    50
    Run Keyword And Expect Error    Withdrawal refused for alice*
    ...    Withdraw Within Limit    alice    151
    Balance Should Be    alice    50

Savings Account Cannot Be Overdrawn
    [Tags]    smoke
    Open Account    carol    type=savings
    Withdrawal Should Fail    carol    1

Many Small Withdrawals
    [Tags]    slow
    Open Funded Account    dave    50
    FOR    ${_}    IN RANGE    50
        Withdraw Within Limit    dave    1
        Sleep    10ms
    END
    Balance Should Be    dave    0

Monthly Interest Is Credited
    [Tags]    wip
    Open Funded Account    erin    1000    type=savings
    Skip    Interest calculation is not implemented yet.
