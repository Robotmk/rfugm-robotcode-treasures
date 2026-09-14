# Solution — Chapter 3

## 1. Regression but not slow

```bash
robotcode discover tests -i regression -e slow
```

Five tests from `overdraft.robot`, including `Monthly Interest Is Credited` (tagged `wip`, but that is not filtered here).

## 2. Why `Transfer Through The Service` is missing

No `-p` was given, so `default-profiles = ["local"]` from `robot.toml` applies, and `local` has
`excludes = ["integration"]`. `discover` honours that exactly like `robot` does — which is the point.

## 3. As the nightly service run sees it

```bash
robotcode -p service discover tests -i regression -e slow
```

Seven tests: the five above plus `Tests.Api.Service.Transfer Through The Service` and
`Tests.Api.Service.Concurrent Transfers Keep Balances Consistent`.

## Bonus

```bash
robotcode -p service --format json discover tests -i regression -e slow | jq -r '.items[].longname'
```

```text
Tests.Accounts.Overdraft.Checking Account Can Be Overdrawn
Tests.Accounts.Overdraft.Withdraw Exactly Up To The Limit
Tests.Accounts.Overdraft.Checking Account Cannot Exceed The Limit
Tests.Accounts.Overdraft.Savings Account Cannot Be Overdrawn
Tests.Accounts.Overdraft.Monthly Interest Is Credited
Tests.Api.Service.Transfer Through The Service
Tests.Api.Service.Concurrent Transfers Keep Balances Consistent
```
