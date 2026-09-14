# AGENTS.md

A small bank (accounts, deposits, withdrawals, transfers) tested with Robot Framework. Use this file as standing
instructions when working in this repository.

## Environment

- Python 3.12, dependencies locked in `uv.lock`. Create the environment with `uv sync`; it lives in `.venv`.
- Run every command through the project environment: `uv run robotcode …` or `.venv/bin/robotcode …`.
- If keywords or versions look wrong, check with `uv run robotcode discover info`.

## Running tests

- Always run tests with `robotcode`, never with plain `robot`: only `robotcode` applies `robot.toml`
  (paths, Python path, profiles, wrapper).
- Profiles (list them with `robotcode profiles list`, inspect with `robotcode -p <name> profiles show`):
  - `local` — in-memory bank, excludes `integration` tests. **Default** when no `-p` is given.
  - `service` — runs against the bank web service at `http://localhost:8765` (sets `${BANK_URL}`).
  - `smoke` / `regression` — select tests by tag.
  - `ci` — CI output: `results/ci`, xUnit file, dotted console, excludes `wip`.
  - Combine them: `robotcode -p local -p smoke robot`, `robotcode -p service -p regression -p ci robot`.
- The `service` profile needs the service: start it with `python3 -m bank.service --port 8765` and stop it afterwards.

## Code layout

- `bank/core.py` — domain logic; `bank/service.py` — JSON web service; `bank/client.py` — HTTP client.
- `bank/BankLibrary.py` — Robot Framework keywords (in-memory, or HTTP when `${BANK_URL}` is set).
- `resources/banking.resource` — project keywords (`Open Funded Account`, `Withdraw Within Limit`).
- `tests/accounts/` — domain tests; `tests/api/` — integration tests against the service.

## Tags

`smoke` quick checks · `regression` full rules · `integration` needs the service · `slow` takes noticeably longer ·
`wip` not implemented yet (skipped) · `flaky` unreliable, excluded from nightly runs.

## How to work

- Find tests and tags with `robotcode discover` (e.g. `robotcode discover tags --tests`), not with grep.
- Look up keywords with `robotcode libdoc bank.BankLibrary list` / `robotcode libdoc bank.BankLibrary show "<Keyword>"`.
- A test fails? Debug it instead of re-running it: `robotcode robot-debug --plain -t "<Test Name>" <file>`,
  then `.where`, `.frame N`, `.vars`, `.print ${var}`.
- Inspect finished runs with `robotcode results summary --failed`, `results log --failed`, `results diff <baseline> <current>`
  — do not read `output.xml` directly.
- Before finishing, run `robotcode analyze code --collect-unused` and `robotcode robot`; both must be clean.
