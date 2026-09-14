*** Settings ***
Documentation    Everyday banking: opening accounts, deposits and transfers.

Resource         banking.resource

Test Tags        smoke


*** Test Cases ***
New Account Starts Empty
    Open Account    alice
    Balance Should Be    alice    0

Deposit Increases Balance
    Open Account    alice
    Deposit    alice    100
    Deposit    alice    50
    Balance Should Be    alice    150

Transfer Moves Money Between Accounts
    Open Funded Account    alice    100
    Open Account    bob    type=savings
    Transfer    alice    bob    30
    Balance Should Be    alice    70
    Balance Should Be    bob    30
    Should Be Equal As Integers    ${LAST_TRANSFER_AMOUNT}    30
