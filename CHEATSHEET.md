# RobotCode Treasures — Cheat Sheet

RobotCode 2.7 · Robot Framework 7.4 · <https://robotcode.io>

## The ten takeaways

0. **RobotCode is a toolkit around one core** — the VS Code extension is only one of its faces.
1. **One project-local environment** — the editor, the terminal and CI all run the same Python.
2. **Model each dimension as a small profile and combine them** — never maintain a matrix of copies.
3. **Ask `discover`, not `grep`** — it sees the project exactly the way the runner does.
4. **Explore in the REPL, keep what works with `.save`** — and clean up what only the REPL understands.
5. **Put setup and teardown into a wrapper** — the editor, the terminal and CI all get it for free.
6. **Don't re-run a failing test to guess** — stop it and look inside, even without a GUI.
7. **Catch errors before running tests** — in the editor, on the command line and in CI, with the same rules.
8. **Query results like data** — `diff` answers "what broke since yesterday?" in one command.
9. **Everything shown tonight is also an agent's toolbox** — give it the plugin and an `AGENTS.md`.

## Commands

### 1 · Environment

```bash
uv sync                                  # or: python -m venv .venv && .venv/bin/pip install -r requirements.txt
robotcode discover info                  # which Python / Robot Framework / RobotCode?
```

VS Code: **RobotCode: Select Python Environment**

### 2 · `robot.toml` and profiles

```toml
default-profiles = ["local"]

[profiles.local]
extend-excludes = ["integration"]        # extend-* adds, the plain key replaces

[profiles.nightly]
inherits = ["service", "regression", "ci"]
extend-excludes = ["flaky"]

[profiles.ci]
enabled = { if = 'environ.get("CI") == "true"' }
```

```bash
robotcode profiles list
robotcode -p service -p smoke profiles show      # the merged result
robotcode -p service -p smoke robot
robotcode discover files                         # after editing .robotignore
```

VS Code: **RobotCode: Select Configuration Profiles**

### 3 · Discover

```bash
robotcode discover tags --tests
robotcode discover tests --search transfer -i smoke
robotcode --format json discover tests -i smoke | jq -r '.items[].longname'
```

### 4 · REPL and notebooks

```bash
robotcode repl
```

`.kw <name>` · `.doc <library>` · `.vars` · `${_}` = last result · `.save [-t NAME] file.robot` · `.help`

VS Code: **RobotCode: New Robot Framework Notebook** (`*.robotbook`)

### 5 · Wrapper

```toml
[profiles.service]
wrapper = ["./with-bank-service.sh"]
```

```bash
robotcode --wrapper ./script.sh robot            # ad hoc
robotcode --no-wrapper -p service robot          # switch it off once
```

### 6 · `robot-debug`

```bash
robotcode robot-debug --break "Keyword Name" -t "Test Name" tests/
printf '.where\n.vars\n.continue\n' | robotcode robot-debug --plain tests/
```

`.where` · `.frame N` · `.vars` · `.print ${x}` · `.list` · `.source <kw>` · `.next` · `.step` · `.continue`

### 7 · Analyzer

```bash
robotcode analyze code --collect-unused
robotcode analyze code --severity error --output-format github --exit-code-mask warn,info,hint
robotcode analyze code --output-format sarif --output-file robotcode.sarif
robotcode analyze cache clear
```

```robotframework
    Log    ${RUNTIME_VAR}    # robotcode: ignore[VariableNotFound]
```

Exit codes: 1 errors · 2 warnings · 4 infos · 8 hints (combined bitwise)

### 8 · Results

```bash
robotcode results summary --failed
robotcode results show --sort elapsed --top 5
robotcode results log --failed --extract ./artifacts
robotcode results stats --by tag
robotcode results diff baseline/output.xml current/output.xml --only new-failures
robotcode --format json results diff baseline.xml current.xml | jq -e '(.newFailures // []) | length == 0'
```

### 9 · AI agents

```bash
claude plugin marketplace add robotcodedev/robotframework-agent-plugins
claude plugin install robotcode@robotframework-agent-plugins
ROBOTCODE_FORCE_AI_AGENT=1 robotcode discover tests      # see what an agent sees
```

VS Code / Copilot Chat: bundled, `robotcode.ai.enableChatPlugins`

## Links

[Documentation](https://robotcode.io) · [What's new](https://robotcode.io/news/) ·
[GitHub](https://github.com/robotcodedev/robotcode) · [Agent plugins](https://github.com/robotcodedev/robotframework-agent-plugins)
