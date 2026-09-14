# Solution — Chapter 8

## 1. What broke

```text
$ robotcode results diff runs/before/output.xml runs/after/output.xml
# Diff — runs/before/output.xml → runs/after/output.xml

## New failures (1)

- Tests.Accounts.Basics.Transfer Moves Money Between Accounts (`tests/accounts/basics.robot:20`) — ✅ **PASS** → ❌ **FAIL**
  > Balance of 'bob' should be 30 but was 29.

_Summary:_ 1 new failures.
```

## 2. Which keyword failed

```text
$ robotcode results log -o runs/after/output.xml --failed
### Test: Tests.Accounts.Basics.Transfer Moves Money Between Accounts (`tests/accounts/basics.robot:20`) ❌ **FAIL**

- **banking.Open Funded Account** `alice` `100` ✅ **PASS**
- **bank.BankLibrary.Open Account** `bob` `type=savings` ✅ **PASS**
- **bank.BankLibrary.Transfer** `alice` `bob` `30` ✅ **PASS**
- **bank.BankLibrary.Balance Should Be** `alice` `70` ✅ **PASS**
- **bank.BankLibrary.Balance Should Be** `bob` `30` ❌ **FAIL**
  > Balance of 'bob' should be 30 but was 29.
```

## 3. The likely culprit

Alice's balance is correct (70), Bob received 29 instead of 30: money is withdrawn correctly but one unit is lost on
the way to the target — the deposit part of `Bank.transfer` in `bank/core.py`. (The run was recorded with
`self.deposit(target, amount - 1)`.)

## 4. Slowest tag

```text
$ robotcode results stats -o runs/after/output.xml --by tag
| Name       | Total | Pass | Fail | Skip | Elapsed |
| ---------- | ----: | ---: | ---: | ---: | ------: |
| smoke      |     4 |    3 |    1 |    0 |    3 ms |
| regression |     6 |    5 |    0 |    1 |  686 ms |
| slow       |     1 |    1 |    0 |    0 |  679 ms |
| wip        |     1 |    0 |    0 |    1 |    1 ms |
```

`regression` — almost entirely `Many Small Withdrawals`, which is also tagged `slow`.

## Bonus

```bash
robotcode --format json results diff runs/before/output.xml runs/after/output.xml \
  | jq -e '(.newFailures // []) | length == 0'
```

```text
before vs. before → true,  exit code 0
before vs. after  → false, exit code 1
```

`results diff` itself always exits with 0; the gate is the `jq -e` expression.
