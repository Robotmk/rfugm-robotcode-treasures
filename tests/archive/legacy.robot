*** Settings ***
Documentation       Tests for the old online banking. Nobody dares to delete them.

Library             OldBankingLibrary


*** Test Cases ***
Login To Old Online Banking
    Open Old Banking Portal    https://legacy.bank.example
    Login With PIN    1234
    Balance Should Be    0
