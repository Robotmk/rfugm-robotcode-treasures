# Solution — Chapter 1

There is nothing to commit for this chapter: the result is an environment, and `.venv/` is git-ignored.

## Steps

```bash
uv sync                                   # or: python -m venv .venv && .venv/bin/pip install -r requirements.txt
uv run robotcode discover info            # Robot Framework 7.4.2, RobotCode 2.7.0, Executable .venv/bin/python
uv run robotcode robot tests/accounts/basics.robot
```

In VS Code: **RobotCode: Select Python Environment** → `.venv/bin/python`, then run `basics.robot` from the Test Explorer.

Output of the terminal run:

```text
New Account Starts Empty                                              | PASS |
Deposit Increases Balance                                             | PASS |
Transfer Moves Money Between Accounts                                 | PASS |
3 tests, 3 passed, 0 failed
```

## Bonus

```bash
python -m venv playground/.venv
playground/.venv/bin/pip install "robotframework==7.3.2" "robotcode[runner]==2.7.0"
playground/.venv/bin/robotcode discover info    # Robot Framework 7.3.2
.venv/bin/robotcode discover info               # Robot Framework 7.4.2
```

Each environment reports its own Robot Framework. If the editor used one and the terminal the other, keywords,
argument conversion and even syntax support could differ — `discover info` is the quickest way to find out which
one you are running.
