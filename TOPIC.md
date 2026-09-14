# Chapter 4 — REPL and notebooks

> ⏱ 15 minutes · 📚 [REPL reference](https://robotcode.io/03_reference/repl) · [What's new in 2.6](https://robotcode.io/news/2026-06-09-whats-new-v2.6.0)

## Pain

You want to find out how `Transfer` behaves when the target account does not exist. The usual loop: write a
throw-away test, run it, open `log.html`, change one line, run it again, … Five minutes for a question that
should take ten seconds.

## Treasure

**`robotcode repl`** — an interactive Robot Framework shell, heavily extended in RobotCode 2.6:

- tab and as-you-type completion for keywords, variables and imports; syntax highlighting; multi-line `FOR` / `IF` blocks
- persistent history across sessions (↑ and `Ctrl+R`)
- `.kw <name>` and `.doc <library>` open the documentation right in the terminal
- `${_}` always holds the result of the last keyword call
- `.save <file>` turns your session into a runnable `.robot` test
- `.vars`, `.imports`, `.help`

**Robot Framework notebooks** (`*.robotbook`) — the same live session in VS Code, split into cells with rendered
log output next to each cell. Create one with **RobotCode: New Robot Framework Notebook**.

## Demo

```text
$ robotcode repl
> Import Library    bank.BankLibrary
> .kw Transfer
> Open Account    alice
> Deposit    alice    100
> Open Account    bob    type=savings
> Transfer    alice    bob    30
> Get Balance    bob
> Log    Bob has ${_}
> Transfer    alice    nobody    10
> .save -t "Explore Transfers" exploration.robot
> .exit
```

Then open `notebooks/bank.robotbook`, run the first cell and continue the exploration there.

## Exercise

1. Start `robotcode repl` and import the bank library.
2. Open two accounts, deposit money, transfer between them. Use `${_}` to log the resulting balance.
3. Try something that should fail — withdraw more than the overdraft limit from a checking account. What is the limit? (`.kw Open Account`)
4. Save your session with `.save exploration.robot` and run it: `robotcode robot exploration.robot`.
   Does it pass? If not, fix the file until it does.

### Bonus

In `notebooks/bank.robotbook`, write a cell with a `FOR` loop that makes ten deposits of 10 and then checks the
balance with `Balance Should Be`. Then add a Markdown cell that explains what you found out in exercise 3.

## Hints

<details><summary>Hint 1 — <code>No keyword with name 'Open Account' found</code></summary>

Import the library first: `Import Library    bank.BankLibrary`. Start the REPL from the project root, where
`robot.toml` puts the project on the Python path.
</details>

<details><summary>Hint 2 — the saved test fails with <code>Variable '${_}' not found</code></summary>

`${_}` is a REPL convenience; it does not exist in a normal test run. `.save` writes your lines as they are.
Replace the `${_}` usage with a real assignment, e.g. `${balance}    Get Balance    bob`.
</details>

<details><summary>Hint 3 — a failing keyword stops nothing</summary>

In the REPL a failing keyword just prints the error, and the session goes on. In the saved test it would fail the
test — wrap expected failures in `Run Keyword And Expect Error` or use `Withdrawal Should Fail`.
</details>

<details><summary>Hint 4 — the notebook asks for a kernel</summary>

Pick *Robot Framework REPL*. The notebook uses the Python environment selected for RobotCode (chapter 1).
</details>

## Self-check

```bash
robotcode robot exploration.robot
```

```text
1 test, 1 passed, 0 failed
```

## Takeaway

**Explore in the REPL, keep what works with `.save` — and clean up what only the REPL understands.**
