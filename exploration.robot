*** Settings ***
Library    bank.BankLibrary

*** Test Cases ***
Explore Transfers
    Open Account    alice
    Deposit    alice    100
    Open Account    bob    type=savings
    Transfer    alice    bob    30
    ${balance}    Get Balance    bob
    Log    Bob has ${balance}
    Balance Should Be    alice    70
    Withdrawal Should Fail    alice    171
