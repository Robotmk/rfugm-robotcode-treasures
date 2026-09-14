# Chapter 3 — `discover`: what tests do I actually have?

> ⏱ 8 minutes · 📚 [Discovering tests](https://robotcode.io/03_reference/discovering-tests)

## Pain

"Which tests are tagged `smoke`?" The usual answer:

```bash
grep -rn "smoke" tests
```

```text
tests/accounts/basics.robot:6:Test Tags        smoke
tests/accounts/overdraft.robot:27:    [Tags]    smoke
```

Two hits — but how many *tests* is that? `Test Tags` applies to every test in the file, tags can come from
`__init__.robot`, profiles filter tests, `.robotignore` hides files, pre-run modifiers change the suite. `grep` knows
none of that. You end up running the tests just to find out which ones would run.

## Treasure

`robotcode discover` builds the real suite tree **without executing anything** — with the same configuration,
profiles and filters that `robotcode robot` would use.

| Command | Answers |
|---|---|
| `discover all` | the complete tree: suites, tests, tasks |
| `discover tests` / `tasks` / `suites` | flat lists |
| `discover tags --tests` | which tests carry which tag |
| `discover files` | which files would be parsed |
| `discover info` | which Python, Robot Framework, RobotCode |

Since RobotCode 2.6: `--search` / `--search-regex` across names, tags and documentation, Markdown output in the
terminal, a compact diagnostics summary, and `--format json` for scripts.

## Demo

```bash
robotcode discover tags --tests
robotcode discover tests --search transfer
robotcode discover tests -i smoke
robotcode -p service discover tests -i smoke        # a different profile, a different answer
robotcode --format json discover tests -i smoke | jq -r '.items[].longname'
```

## Exercise

1. List all tests tagged `regression` but **not** `slow`.
2. Look closely at the result: `Transfer Through The Service` is tagged `regression`, yet it is missing. Why?
3. Now list the same selection as the **nightly service run** would see it.

### Bonus

Produce a plain list of long names — one per line, nothing else — for the tests of exercise 3. A CI pipeline could
use such a list to split tests across parallel jobs (`robotcode robot --by-longname …`).

## Hints

<details><summary>Hint 1 — tag filters</summary>

`discover tests` accepts the same `-i/--include` and `-e/--exclude` options as `robot`.
</details>

<details><summary>Hint 2 — the missing test</summary>

Which profile is active when you do not pass `-p`? Look at `default-profiles` in `robot.toml`, or run
`robotcode profiles list` and check the *Active* column.
</details>

<details><summary>Hint 3 — machine-readable output</summary>

`--format json` is a global option and goes **before** the subcommand. Every entry in `items` has a `longname`.
</details>

## Self-check

```bash
robotcode discover tests -i regression -e slow
```

lists these five tests (the default profile `local` excludes integration tests):

```text
Tests.Accounts.Overdraft.Checking Account Can Be Overdrawn
Tests.Accounts.Overdraft.Withdraw Exactly Up To The Limit
Tests.Accounts.Overdraft.Checking Account Cannot Exceed The Limit
Tests.Accounts.Overdraft.Savings Account Cannot Be Overdrawn
Tests.Accounts.Overdraft.Monthly Interest Is Credited
```

With `-p service`, two more appear: `Tests.Api.Service.Transfer Through The Service` and
`Tests.Api.Service.Concurrent Transfers Keep Balances Consistent`.

## Takeaway

**Ask `discover`, not `grep` — it sees the project exactly the way the runner does.**
