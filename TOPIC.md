# Chapter 1 — Getting started: environments with uv and pip

> ⏱ 10 minutes · 📚 [Get started](https://robotcode.io/02_get_started/)

## 😖 Pain

"Works on my machine." The test runs fine from the ▶ button, but fails in the terminal with
`No keyword with name 'Open Account' found` — or the other way round. The editor and the terminal use different
Pythons with different libraries installed, and nobody notices until something breaks.

## 💎 Treasure

A **project-local environment** (`.venv`) that is created in seconds and used by *everything*: RobotCode in the
editor, the `robotcode` command in the terminal, and later your CI pipeline.

- RobotCode runs Robot Framework **from the Python interpreter you select** — the libraries, versions and keywords
  it knows are exactly those of that environment.
- `robotcode discover info` tells you at any time which Python, Robot Framework and RobotCode are in use.

This Codespace ships [uv](https://docs.astral.sh/uv/) but deliberately **no environment** yet.

## 🖥️ Demo

1. Open `tests/accounts/basics.robot`. RobotCode cannot find Robot Framework — there is no environment yet.
2. Create the environment from `pyproject.toml` and the lock file:

   ```bash
   uv sync
   ```

   Without uv, the classic way gives the same result:

   ```bash
   python -m venv .venv
   .venv/bin/pip install -r requirements.txt
   ```

3. Command palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) → **RobotCode: Select Python Environment** → `.venv`.
4. Run `New Account Starts Empty` with the ▶ button next to it, then the same in the terminal:

   ```bash
   uv run robotcode robot tests/accounts/basics.robot
   ```

## 🛠️ Exercise

1. Create the environment with `uv sync` (or with pip, see above).
2. Select it as the Python environment for RobotCode.
3. Run `tests/accounts/basics.robot` from the **Test Explorer** (flask icon in the activity bar).
4. Run the same file in the terminal with `robotcode`.

### ⭐ Bonus

Create a second environment in `playground/` with an **older Robot Framework**, and see how RobotCode reports the
difference:

```bash
python -m venv playground/.venv
playground/.venv/bin/pip install "robotframework==7.3.2" "robotcode[runner]==2.7.0"
playground/.venv/bin/robotcode discover info
```

Which Robot Framework version does each environment report? What would happen if the editor used one and
your terminal the other?

## 💡 Hints

<details><summary>Hint 1 — RobotCode still complains after <code>uv sync</code></summary>

RobotCode uses the interpreter selected in VS Code. Run **RobotCode: Select Python Environment** and pick the
interpreter inside `.venv`. If the list does not show it, choose *Enter interpreter path* and use `.venv/bin/python`.
</details>

<details><summary>Hint 2 — <code>robotcode: command not found</code></summary>

The environment is not activated in your terminal. Either use `uv run robotcode …`, call `.venv/bin/robotcode …`
directly, or activate it with `source .venv/bin/activate`. A new terminal opened *after* selecting the interpreter
is usually activated automatically.
</details>

<details><summary>Hint 3 — the Test Explorer is empty</summary>

Tests are discovered once the environment is selected. Use the refresh button at the top of the Test Explorer,
or run **RobotCode: Clear Cache and Restart Language Servers**.
</details>

## ✅ Self-check

```bash
uv run robotcode discover info
```

Expected (Python patch version and platform lines may differ):

```text
# Info

- _Robot Framework:_ 7.4.2
- _RobotCode:_ 2.7.0
- _Python:_ 3.12.x
- _Executable:_ .venv/bin/python
```

and in the Test Explorer, all three tests of `basics.robot` are green.

## 🔑 Takeaway

**One project-local environment — the editor, the terminal and CI all run the same Python.**
