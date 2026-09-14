*** Settings ***
Documentation    The same banking rules, exercised through the bank web service.
...              Needs a running service and the variable \${BANK_URL} (see the ``service`` profile).

Resource         banking.resource

Suite Setup      Service Should Be Healthy

Test Tags        integration


*** Test Cases ***
Service Is Healthy
    Service Should Be Healthy

Transfer Through The Service
    [Tags]    regression
    Open Funded Account    alice    100
    Open Account    bob
    Transfer    alice    bob    40
    Balance Should Be    alice    60
    Balance Should Be    bob    40

Concurrent Transfers Keep Balances Consistent
    [Tags]    regression    flaky
    Open Funded Account    alice    100
    Open Funded Account    bob    100
    FOR    ${_}    IN RANGE    20
        Transfer    alice    bob    5
        Transfer    bob    alice    5
    END
    Balance Should Be    alice    100
    Balance Should Be    bob    100
