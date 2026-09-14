# Chapter 6 — `robot-debug`: debugging without a GUI

> ⏱ 12 minutes · 📚 [robot-debug reference](https://robotcode.io/03_reference/robot-debug)

## Pain

Since this morning, one regression test fails:

```text
Withdraw Exactly Up To The Limit                                      | FAIL |
Withdrawal refused for alice: overdraft limit exceeded.
```

It happens in CI, in a container, over SSH — no VS Code, no gutter breakpoints. The usual reaction: sprinkle
`Log` statements into the keyword, run again, look at the log, move the `Log`, run again, …

## Treasure

**`robotcode robot-debug`** (new in RobotCode 2.6) runs the real suite through the same runner as `robotcode robot`
— same profiles, same wrapper — but stops at breakpoints and failures with a `pdb`-style prompt `(rdb)`.

| Command | What it does |
|---|---|
| `--break file:line`, `--break "Keyword Name"` | breakpoints from the command line (conditions: `.break <loc>, <expr>`) |
| *(default)* | stops at uncaught failures — often exactly where you want to look |
| `.where` / `.frame N` / `.up` / `.down` | call stack and frame selection |
| `.vars`, `.print ${x}`, `.whatis ${x}` | inspect variables and evaluate expressions in the selected frame |
| `.list`, `.source <keyword>` | show the code around the stop / a keyword's definition |
| `.next`, `.step`, `.return`, `.continue` | step over, step into, run to return, resume |
| `.set ${x} <value>` | change a variable and try what would happen |

Also: the `Breakpoint` keyword from `robotcode.repl.Repl` — a no-op in normal runs, a stop under the debugger.
And `--plain` for scripted, non-interactive sessions (chapter 9 will need that).

## Demo

```bash
robotcode robot-debug -t "Withdraw Exactly Up To The Limit" tests/accounts/overdraft.robot
```

```text
* exception  BuiltIn.Fail  (resources/banking.resource:21)  — Keyword failed: Withdrawal refused …
(rdb) .where
(rdb) .frame 3
(rdb) .vars
(rdb) .print ${amount}
(rdb) .source Withdraw Within Limit
(rdb) .continue
```

## Exercise

1. Run the failing test **once** under `robotcode robot-debug`.
2. Find out why a withdrawal of exactly `balance + limit` is refused — using only the debugger prompt.
3. Fix the bug and run the whole overdraft suite normally.

### Bonus

Drive the debugger **without typing** — the way an AI agent or a CI job would:

```bash
printf '.where\n.frame 3\n.vars\n.continue\n' | robotcode robot-debug --plain -t "Withdraw Exactly Up To The Limit" tests/accounts/overdraft.robot
```

Then add `Library    robotcode.repl.Repl` to `resources/banking.resource`, put `Breakpoint` right before the
`IF`, and compare a normal `robotcode robot` run with a `robotcode robot-debug` run.

## Hints

<details><summary>Hint 1 — the debugger stops inside <code>Fail</code></summary>

That is the innermost frame. `.where` shows the stack; the interesting variables live in the frame of
`Withdraw Within Limit`. Select it with `.frame <number>`.
</details>

<details><summary>Hint 2 — which values matter?</summary>

`.vars` in that frame shows `${amount}`, `${balance}`, `${limit}` and `${available}`. Is `150` really more than
what is available?
</details>

<details><summary>Hint 3 — where is the condition?</summary>

`.list` or `.source Withdraw Within Limit` shows the `IF`. Try `.print ${amount} > ${available}` versus
`.print ${amount} >= ${available}`.
</details>

## Self-check

```bash
robotcode robot tests/accounts/overdraft.robot
```

```text
6 tests, 5 passed, 0 failed, 1 skipped
```

## Takeaway

**Don't re-run a failing test to guess — stop it and look inside, even without a GUI.**
