*** Settings ***
Documentation    Project keywords built on top of the bank library.

Library          bank.BankLibrary


*** Keywords ***
Open Funded Account
    [Documentation]    Opens an account for ``owner`` and deposits ``amount``.
    [Arguments]    ${owner}    ${amount}    ${type}=checking
    Open Account    ${owner}    type=${type}
    Deposit    ${owner}    ${amount}

Withdraw Within Limit
    [Documentation]    Withdraws ``amount`` unless it exceeds the balance plus the overdraft limit.
    [Arguments]    ${owner}    ${amount}
    ${balance}    Get Balance    ${owner}
    ${limit}    Get Limit    ${owner}
    ${available}    Evaluate    ${balance} + ${limit}
    ${message}    Set Variable    Withdrawal of ${amount} refused
    IF    ${amount} > ${available}
        Fail    Withdrawal refused for ${owner}: overdraft limit exceeded.
    END
    Withdraw    ${owner}    ${amount}

Close Account
    [Documentation]    Withdraws the whole balance so the account can be closed.
    [Arguments]    ${owner}
    ${balance}    Get Balance    ${owner}
    IF    ${balance} > 0    Withdraw    ${owner}    ${balance}
