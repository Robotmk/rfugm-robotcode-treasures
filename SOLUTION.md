# Solution — Chapter 9

## Agent detection

```bash
robotcode discover tests -i smoke                              # formatted, colored terminal output
ROBOTCODE_FORCE_AI_AGENT=1 robotcode discover tests -i smoke   # plain Markdown, no colors, no pager
```

Inside Claude Code, Copilot or Cursor you get the second form automatically.

## `AGENTS.md`

See `AGENTS.md` in this branch — it covers environment, running through `robotcode`, profiles and how to combine
them, the service, code layout, tags, and which `robotcode` commands to prefer.

## What the agent should do with the demo prompts

| Prompt | Expected approach |
|---|---|
| Which smoke tests exist? | `robotcode discover tests -i smoke` → four tests |
| Run the regression tests with the local and ci profiles | `robotcode -p local -p regression -p ci robot` → 5 tests, 1 failed |
| Why does "Withdraw Exactly Up To The Limit" fail? | `robotcode robot-debug --plain -t …`, `.frame 3`, `.vars` → `>=` instead of `>` in `Withdraw Within Limit`; fixed in this branch |
| What broke between runs/before and runs/after? | `robotcode results diff runs/before/output.xml runs/after/output.xml` → `Transfer Moves Money Between Accounts`, Bob receives 29 instead of 30 → `Bank.transfer` in `bank/core.py` |
| Which arguments does Open Account take? | `robotcode libdoc bank.BankLibrary show "Open Account"` → `owner`, `type` (`checking` / `savings`), `limit` |

Warning signs that the plugin or the project context is missing: `grep` on `.robot` files, reading `output.xml`,
re-running a failing test repeatedly, or calling plain `robot`.
