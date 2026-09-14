# Chapter 8 — `results`: what happened, without opening `log.html`

> ⏱ 12 minutes · 📚 [Analyzing results](https://robotcode.io/03_reference/analyzing-results)

## Pain

The nightly run is red. The report is an 80 MB `log.html` that takes a minute to open in the browser, over a VPN,
on a phone. And the only question you really have is: **what broke since yesterday — and why?**

## Treasure

**`robotcode results`** (new in RobotCode 2.6) queries a finished run's `output.xml` / `output.json` from the
terminal:

| Command | Answers |
|---|---|
| `results summary --failed` | overall status and every failure with its message |
| `results show --sort elapsed --top 5` | one line per test — sortable, filterable |
| `results log --failed` | the execution tree of the selected tests: keywords, arguments, messages |
| `results stats --by tag` | pass/fail/elapsed grouped by tag or suite |
| `results diff BASELINE CURRENT` | new failures, new passes, added and removed tests |

All of them take Robot's filters (`-i`, `-e`, `-t`, `-s`, `--status`), `--search` / `--search-regex`, and
`--format json` for scripts. `log --extract DIR` writes embedded screenshots and files to disk.
Without `-o`, the latest output of the active profile is used.

This branch contains two recorded runs: `runs/before/output.xml` (yesterday) and `runs/after/output.xml` (today).

## Demo

```bash
robotcode results summary -o runs/after/output.xml --failed
robotcode results show -o runs/after/output.xml --sort elapsed --top 3
robotcode results stats -o runs/after/output.xml --by tag
robotcode results diff runs/before/output.xml runs/after/output.xml
```

## Exercise

Using only `robotcode results`:

1. Which test broke between `runs/before` and `runs/after`?
2. Which keyword call inside that test failed, with which arguments?
3. From the failure message, which part of the bank is the likely culprit?
4. Which tag has the largest total elapsed time in today's run?

### Bonus

A CI job should fail **only if there are new failures compared to the baseline** — not because of failures that
were already there. Write a one-liner with `robotcode --format json results diff … | jq -e …` whose exit code is
`0` for "no new failures" and non-zero otherwise. Test it with `runs/before` against itself, and against `runs/after`.

## Hints

<details><summary>Hint 1 — which command for which question</summary>

Question 1: `diff`. Question 2: `log` with `--failed`. Question 4: `stats --by tag`.
</details>

<details><summary>Hint 2 — reading the log tree</summary>

`results log` prints the keyword tree of each selected test; the failing call is marked ❌ with its arguments.
Library keywords show their library (`bank.BankLibrary.…`), resource keywords their resource (`banking.…`).
</details>

<details><summary>Hint 3 — JSON structure of <code>diff</code></summary>

`robotcode --format json results diff runs/before/output.xml runs/after/output.xml | jq .` — look at `newFailures`.
</details>

## Self-check

<details><summary>Expected answers</summary>

1. `Tests.Accounts.Basics.Transfer Moves Money Between Accounts` (PASS → FAIL)
2. `Balance Should Be    bob    30` — message `Balance of 'bob' should be 30 but was 29.`
3. `Transfer` itself passed, but the target received one less than was sent — the transfer logic.
4. `regression` (the `slow` test `Many Small Withdrawals` is part of it).

Bonus: the one-liner exits with `0` for `before` vs. `before` and with `1` for `before` vs. `after`.
</details>

## Takeaway

**Query results like data — `diff` answers "what broke since yesterday?" in one command.**
