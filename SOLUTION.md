# Solution — Chapter 6

## The debugger session

```text
$ robotcode robot-debug -t "Withdraw Exactly Up To The Limit" tests/accounts/overdraft.robot
* exception  BuiltIn.Fail  (resources/banking.resource:21)  — Keyword failed: Withdrawal refused for alice: overdraft limit exceeded.
(rdb) .where
> #0  BuiltIn.Fail                      resources/banking.resource:21
  #1  IF                                resources/banking.resource:20
  #2  IF/ELSE ROOT                      resources/banking.resource:20
  #3  banking.Withdraw Within Limit     tests/accounts/overdraft.robot:17
  #4  Withdraw Exactly Up To The Limit  tests/accounts/overdraft.robot:15
  #5  Overdraft                         tests/accounts/overdraft.robot
(rdb) .frame 3
(rdb) .vars
Local:
    ${amount} = '150'
    ${available} = 150
    ${balance} = 50
    ${limit} = 100
    ${owner} = 'alice'
(rdb) .print ${amount} >= ${available}
${amount} >= ${available} = True
```

Balance 50 plus limit 100 makes 150 available, and exactly 150 is requested — which must be allowed. The condition
in `Withdraw Within Limit` uses `>=` where it must use `>`.

## The fix

`resources/banking.resource`:

```robotframework
    IF    ${amount} > ${available}
        Fail    Withdrawal refused for ${owner}: overdraft limit exceeded.
    END
```

```bash
robotcode robot tests/accounts/overdraft.robot     # 6 tests, 5 passed, 0 failed, 1 skipped
```

## Bonus

The piped session prints the same stack and variables and then lets the run finish — no terminal interaction needed.
With `Breakpoint` placed before the `IF`, `robotcode robot` runs straight through, while `robotcode robot-debug`
stops at that line.
