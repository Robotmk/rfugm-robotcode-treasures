# Chapter 7 — Analyzer, diagnostics modifiers, Robocop, CI

> ⏱ 15 minutes · 📚 [Analyzing code](https://robotcode.io/03_reference/analyzing-code) · [Diagnostics modifiers](https://robotcode.io/03_reference/diagnostics-modifiers)

## Pain

A typo in a keyword name or a variable nobody defines — the editor shows a red squiggle, but only for the person
who has the file open. Everybody else finds out in the nightly run, hours later. Meanwhile, resource files collect
keywords nobody calls any more, and a handful of "known false positives" train the team to ignore the Problems view.

## Treasure

**`robotcode analyze code`** runs the editor's analysis on the command line — the same rules, the same
`robot.toml`, no test execution.

- `--collect-unused` finds unused keywords and variables (RobotCode 2.5).
- `--severity error,warning` and `--code KeywordNotFound` filter the output (2.6).
- `--output-format github | gitlab | sarif | json` for CI annotations, merge-request widgets and code scanning (2.6).
- **Bitwise exit codes:** 1 = errors, 2 = warnings, 4 = infos, 8 = hints (errors + warnings = 3).
  `--exit-code-mask warn,info,hint` lets only errors fail the build.
- **Diagnostics modifiers** decide what a finding means for *this* project:
  `# robotcode: ignore[VariableNotFound]` at the end of a line, indented inside a block, or at column 0 for the rest of
  the file — or project-wide in `robot.toml`:

  ```toml
  [tool.robotcode-analyze.modifiers]
  ignore = ["VariableNotFound"]
  warning = ["KeywordNotFound"]
  ```

- **Robocop** adds style and best-practice rules and formatting, right inside the editor (Format Document).
- A persistent **analysis cache** makes the second run fast: `robotcode analyze cache info`, `… cache clear`.

This branch has three findings planted: an unused keyword, an unused variable, and a variable the library creates
at runtime (`${LAST_TRANSFER_AMOUNT}`, set by `Transfer`) — invisible to static analysis.

## Demo

```bash
robotcode analyze code
robotcode analyze code --collect-unused; echo "exit code: $?"
robotcode analyze code --collect-unused --severity error
robotcode analyze code --collect-unused --output-format github
robotcode analyze cache info
```

Then:

- open `.github/workflows/analyze.yml` — annotations plus a SARIF upload for GitHub code scanning;
- open `resources/banking.resource` — Robocop flags `Set Variable` (use `VAR`) in the Problems view; run *Format Document*.

## Exercise

1. Make `robotcode analyze code --collect-unused` exit with code `0`:
   - remove what is really unused,
   - keep `${LAST_TRANSFER_AMOUNT}` in the test, and tell RobotCode that this one finding is expected — **only on that line**.
2. Check that the tests still pass: `robotcode robot tests/accounts`.

### Bonus

- Produce GitHub annotations and make the command fail **only on errors**, not on warnings.
- Write the unused findings as a SARIF file and count the results with `jq '.runs[0].results | length'`.

### Bonus treasures (if time permits)

- **`Literal` completion:** in a test, type `Open Account    alice    type=` and press `Ctrl+Space`. The allowed values
  come from the type hint `Literal["checking", "savings"]` in `bank/BankLibrary.py` (RobotCode 2.5).
- **Experimental SemanticModel:** set `"robotcode.experimental.semanticModel": true` (or
  `semantic-model = true` under `[tool.robotcode-analyze]`) for deeper variable resolution — a preview of what comes next.

## Hints

<details><summary>Hint 1 — what is "really unused"?</summary>

`--collect-unused` reports `Close Account` (no caller) and `${message}` in `Withdraw Within Limit` (assigned, never
read). Both can go.
</details>

<details><summary>Hint 2 — silencing one line</summary>

A comment at the end of the line applies to that line only:

```robotframework
    Should Be Equal As Integers    ${LAST_TRANSFER_AMOUNT}    30    # robotcode: ignore[VariableNotFound]
```
</details>

<details><summary>Hint 3 — exit codes</summary>

`echo $?` right after the command. Mask the severities that must not fail the build with `--exit-code-mask`.
</details>

## Self-check

```bash
robotcode analyze code --collect-unused; echo "exit code: $?"
```

```text
Files: 4, Errors: 0, Warnings: 0, Infos: 0, Hints: 0
exit code: 0
```

## Takeaway

**Catch errors before running tests — in the editor, on the command line and in CI, with the same rules.**
