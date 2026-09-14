# Chapter 9 — Working with AI agents

> ⏱ 15 minutes · 📚 [Working with AI agents](https://robotcode.io/03_reference/ai-agents) · [Agent plugins](https://github.com/robotcodedev/robotframework-agent-plugins)

## 😖 Pain

Ask a coding agent "which smoke tests do we have?" and watch it `grep` through `.robot` files — missing every test
that gets its tag from `Test Tags`. Ask "why did the nightly fail?" and it loads a multi-megabyte `output.xml` into
its context. Ask it to fix a failing test and it re-runs it again and again, or invents a keyword that does not exist
in *your* installed library version. On top of that, colored terminal output and pagers garble what it reads.

## 💎 Treasure

Everything you have seen tonight is also an agent's toolbox:

| The agent wants to know… | …and should use |
|---|---|
| which tests, tasks, tags exist | `robotcode discover` (ch. 3) |
| how a keyword is called | `robotcode libdoc` — the installed versions, not training data |
| how to run something | `robotcode -p … robot` with the project's profiles (ch. 2, 5) |
| why a test fails | `robotcode robot-debug --plain` (ch. 6) |
| how an idea works before writing a test | `robotcode repl` (ch. 4) |
| what a finished run says | `robotcode results` (ch. 8) |
| whether the code is sound | `robotcode analyze code` (ch. 7) |

Two things make this work:

- **The RobotCode agent plugin** teaches agents these habits. It is bundled with the VS Code extension for GitHub
  Copilot Chat (`robotcode.ai.enableChatPlugins`, on by default) and published as a marketplace for Claude Code,
  GitHub Copilot CLI and Codex: `robotcodedev/robotframework-agent-plugins`.
- **Agent detection in the CLI** (RobotCode 2.6): inside Claude Code, Copilot or Cursor sessions, `robotcode` switches
  off colors and pagers automatically, and interactive tools use the plain backend. Override with
  `ROBOTCODE_FORCE_AI_AGENT=1` or `ROBOTCODE_NO_AI_AGENT=1`.

And one thing only you can provide: **project context** in an `AGENTS.md` (or `CLAUDE.md`,
`.github/copilot-instructions.md`) — how to create the environment, which profiles mean what, which services the
tests need.

This branch brings back two things from earlier chapters for the agent to work on: the overdraft bug from
chapter 6 and the recorded runs from chapter 8.

## 🖥️ Demo (presenter, with Claude Code)

```bash
claude plugin marketplace add robotcodedev/robotframework-agent-plugins
claude plugin install robotcode@robotframework-agent-plugins
claude
```

Prompts — watch which `robotcode` commands the agent chooses:

1. *"Which smoke tests exist in this project?"*
2. *"Run the regression tests with the local and ci profiles."*
3. *"Why does 'Withdraw Exactly Up To The Limit' fail? Use the debugger, don't guess. Then fix it."*
4. *"What broke between runs/before and runs/after, and where would you look in the code?"*
5. *"Which arguments does Open Account take, and which values are allowed for type?"*

## 🛠️ Exercise — for everyone

1. See agent detection at work. In a terminal, compare:

   ```bash
   robotcode discover tests -i smoke
   ROBOTCODE_FORCE_AI_AGENT=1 robotcode discover tests -i smoke
   ```

2. Write an `AGENTS.md` in the project root that a new colleague — human or agent — needs on day one. Use the
   checklist in the self-check below.

## 🛠️ Exercise — if you have an agent

- **Claude Code in this Codespace:** `curl -fsSL https://claude.ai/install.sh | bash`, then `claude` and log in.
  Install the plugin with the two commands from the demo.
- **GitHub Copilot Chat in VS Code:** the plugin is already bundled — just open the chat in *Agent* mode.
- **Copilot CLI / Codex:** `copilot plugin marketplace add …` / `codex plugin marketplace add …`, see the
  [plugin README](https://github.com/robotcodedev/robotframework-agent-plugins).

Ask the prompts from the demo — before and after creating your `AGENTS.md`. What changes?

## 💡 Hints

<details><summary>Hint 1 — what to look for in the comparison</summary>

In a normal terminal, `discover` renders formatted, colored output and may open a pager. With agent detection
you get plain Markdown — exactly what an agent can read reliably.
</details>

<details><summary>Hint 2 — the agent still greps</summary>

Mention Robot Framework or RobotCode explicitly in your prompt, or invoke the skill by name. In VS Code, check that
`robotcode.ai.enableChatPlugins` is enabled.
</details>

<details><summary>Hint 3 — the agent uses the wrong libraries</summary>

Let it run `robotcode discover info`: it shows which Python and Robot Framework it is really using. Put
`uv sync` / `.venv` into your `AGENTS.md`.
</details>

## ✅ Self-check

Your `AGENTS.md` answers these questions:

- [ ] How is the environment created, and which interpreter is used? (`uv sync`, `.venv`)
- [ ] How are tests run — and why always through `robotcode`, not plain `robot`?
- [ ] What do the profiles `local`, `service`, `smoke`, `regression`, `ci` mean, and how are they combined?
- [ ] What does the `service` profile need, and how is the service started?
- [ ] Where do keywords live (`bank/BankLibrary.py`, `resources/banking.resource`)?
- [ ] What do the tags `smoke`, `regression`, `integration`, `slow`, `wip`, `flaky` mean?
- [ ] Which `robotcode` commands should be used to discover tests, debug failures and inspect results?

## 🔑 Takeaway

**Everything shown tonight is also an agent's toolbox — give it the plugin and an `AGENTS.md`.**
