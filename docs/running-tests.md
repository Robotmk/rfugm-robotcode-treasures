# Running the tests

All settings live in `robot.toml`. List the profiles with `robotcode profiles list` and combine them with `-p`:

| What | Command |
|---|---|
| Quick check while developing | `robotcode -p local -p smoke robot` |
| Regression, in-memory | `robotcode -p local -p regression robot` |
| Regression against the service | `robotcode -p service -p regression robot` |
| Like CI | `robotcode -p local -p ci robot` |
| Nightly | `robotcode -p nightly robot` |

In VS Code: **RobotCode: Select Configuration Profiles**, then use the Test Explorer.
Start the service first for `service` and `nightly`: `python -m bank.service --port 8765`.
