# Solution — Chapter 4

## REPL session

```text
> Import Library    bank.BankLibrary
> Open Account    alice
> Deposit    alice    100
> Open Account    bob    type=savings
> Transfer    alice    bob    30
> Get Balance    bob
> Log    Bob has ${_}
[ INFO ] Bob has 30
> .kw Open Account
> Withdraw    alice    171
[ FAIL ] BankError: Withdrawing 171 from 'alice' exceeds the limit: balance 70, limit 100.
> .save exploration.robot
```

## The saved test needed a fix

Run as saved, the test fails:

```text
Explore Transfers                                                     | FAIL |
Variable '${_}' not found.
```

`${_}` only exists inside the REPL, and the failing `Withdraw` would fail the test as well. The cleaned-up version
in `exploration.robot` assigns the balance to a real variable and turns the expected failure into an assertion:

```robotframework
    ${balance}    Get Balance    bob
    Log    Bob has ${balance}
    Balance Should Be    alice    70
    Withdrawal Should Fail    alice    171
```

```bash
robotcode robot exploration.robot     # 1 test, 1 passed, 0 failed
```

## Bonus

`notebooks/bank.robotbook` contains the `FOR` loop cell and a Markdown cell with the findings:
the default overdraft limit of a checking account is 100, so with a balance of 70 the maximum withdrawal is 170.
