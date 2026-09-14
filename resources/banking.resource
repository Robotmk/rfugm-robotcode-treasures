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
    IF    ${amount} > ${available}
        Fail    Cannot withdraw ${amount} from ${owner}: only ${available} available.
    END
    Withdraw    ${owner}    ${amount}
