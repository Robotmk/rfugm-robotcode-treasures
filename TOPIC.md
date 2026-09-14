# Chapter 2 — `robot.toml`, profiles and `.robotignore`

> ⏱ 15 minutes · 📚 [Configuration reference](https://robotcode.io/03_reference/config) · [Ignoring files](https://robotcode.io/03_reference/ignoring-files)

## 😖 Pain

A long command line is not the problem — a `launch.json` entry can hold that. The problem is **combinations**.
Our bank tests vary along three independent dimensions:

| Dimension | Options | What changes |
|---|---|---|
| Target | in-memory · web service | `--variable BANK_URL:http://localhost:8765` |
| Scope | smoke · regression · everything | `--include` / `--exclude` |
| Output | developer · CI | `--outputdir`, `--xunit`, `--console`, `--exclude wip` |

2 × 3 × 2 = **12 combinations**. Look at what this branch contains — it is what teams really end up with:

- `.vscode/launch.json` with 12 near-identical run configurations,
- `.gitlab-ci.yml` with its own copy of the flags,
- `docs/running-tests.md` with a third, slightly outdated copy.

Now the change request: **"The bank service moves to port 9000."** Count the places you have to touch
(`grep -rn 8765 .vscode .gitlab-ci.yml docs`). And the colleague who works in IntelliJ, in the terminal or with an
AI agent gets none of the `launch.json` configurations anyway.

On top of that, `tests/archive/legacy.robot` — old tests for a system that no longer exists — breaks every run and
fills the Problems view.

## 💎 Treasure

`robot.toml` is read by **everything that runs `robotcode`**: the ▶ button, the Test Explorer, the debugger, the
terminal, CI and AI agents.

- **Small, orthogonal profiles**, one per option, combined freely: `robotcode -p service -p smoke robot`.
- **Named combinations** through inheritance: `inherits = ["service", "regression", "ci"]`.
- **`extend-*` keys** (`extend-excludes`, `extend-variables`, …) add to inherited or combined values; the plain keys
  replace them. That matters as soon as profiles are combined: with `excludes` in both `local` and `ci`,
  `-p local -p ci` would silently run the integration tests again.
- **Conditions and defaults:** `enabled = { if = 'environ.get("CI") == "true"' }`, `default-profiles = [...]`.
- **Inline documentation** while editing `robot.toml`: hover a key, get completion and validation
  (JSON schema via *Even Better TOML*, since RobotCode 2.6). Typos matter: the runner silently ignores unknown keys.
- **`.robotignore`** (gitignore syntax) keeps folders away from discovery, analysis, the language server and test
  runs. Pitfall: if a root `.robotignore` exists, RobotCode ignores `.gitignore` completely.

## 🖥️ Demo

1. Show `launch.json` and `.gitlab-ci.yml`; count the port occurrences:

   ```bash
   grep -rn 8765 .vscode .gitlab-ci.yml docs | wc -l
   ```

2. Replace the matrix with five profiles in `robot.toml` (hover the keys to show the inline docs):

   ```toml
   default-profiles = ["local"]

   [profiles.local]
   description = "Run against the in-memory bank; skip tests that need the web service"
   extend-excludes = ["integration"]

   [profiles.service]
   description = "Run against the bank web service on localhost:8765"
   variables = { BANK_URL = "http://localhost:8765" }

   [profiles.smoke]
   description = "Only the quick smoke tests"
   includes = ["smoke"]

   [profiles.regression]
   description = "The regression suite"
   includes = ["regression"]

   [profiles.ci]
   description = "Settings for CI pipelines: separate output folder, xUnit report, compact console"
   extend-excludes = ["wip"]
   output-dir = "results/ci"
   xunit = "xunit.xml"
   console = "dotted"
   ```

3. Inspect and combine:

   ```bash
   robotcode profiles list
   robotcode -p service -p smoke profiles show     # the merged result
   robotcode -p local -p smoke robot
   robotcode -p local -p ci profiles show          # both exclusions survive thanks to extend-excludes
   ```

4. Type `include` instead of `includes` in `[profiles.smoke]` — the editor underlines it, while
   `robotcode -p smoke robot` silently runs *all* tests.
5. VS Code: **RobotCode: Select Configuration Profiles** → `local` + `smoke`, run from the Test Explorer.
6. `.robotignore`:

   ```bash
   robotcode discover files                 # lists tests/archive/legacy.robot
   echo "tests/archive/" > .robotignore
   robotcode discover files                 # gone — also from the Problems view and from test runs
   ```

## 🛠️ Exercise

1. Add the five profiles from the demo to `robot.toml` (if you have not typed along).
2. Create a profile **`nightly`** that inherits `service`, `regression` and `ci`, and additionally excludes the tag
   `flaky` — **without** losing the `wip` exclusion it inherits from `ci`.
3. Replace the flags in `.gitlab-ci.yml` and `docs/running-tests.md` with `robotcode -p …` calls.
4. Delete `.vscode/launch.json`.
5. Add a `.robotignore` for `tests/archive/`.

### ⭐ Bonus

- Make `ci` active only when the environment variable `CI` is `true`. Then run
  `robotcode -p nightly discover tests` on your machine: why does a `wip` test suddenly show up?
- Make `local` + `smoke` the default when no profile is given.

## 💡 Hints

<details><summary>Hint 1 — inheriting several profiles</summary>

```toml
[profiles.nightly]
inherits = ["service", "regression", "ci"]
```
</details>

<details><summary>Hint 2 — the <code>wip</code> test appears in <code>nightly</code></summary>

`excludes = [...]` in `nightly` replaces the list inherited from `ci`. There is an `extend-` variant of the key.
</details>

<details><summary>Hint 3 — <code>excludes</code> or <code>extend-excludes</code>?</summary>

Use `extend-excludes` in profiles that are meant to be combined or inherited. Plain `excludes` is for a profile that
deliberately defines the complete list.
</details>

<details><summary>Hint 4 — what did I actually configure?</summary>

`robotcode -p nightly profiles show` prints the fully merged configuration. `robotcode config info list` lists
every valid key.
</details>

<details><summary>Hint 5 — the bonus question</summary>

A profile whose `enabled` condition is false contributes nothing — not even to profiles that inherit it.
</details>

## ✅ Self-check

```bash
robotcode -p nightly profiles show
robotcode -p nightly discover tests
robotcode discover files
```

- `profiles show` contains `excludes = ["wip", "flaky"]`, `includes = ["regression"]`,
  `output-dir = "results/ci"` and `BANK_URL = "http://localhost:8765"`.
- `discover tests` lists exactly these six tests:

  ```text
  Tests.Accounts.Overdraft.Checking Account Can Be Overdrawn
  Tests.Accounts.Overdraft.Withdraw Exactly Up To The Limit
  Tests.Accounts.Overdraft.Checking Account Cannot Exceed The Limit
  Tests.Accounts.Overdraft.Savings Account Cannot Be Overdrawn
  Tests.Accounts.Overdraft.Many Small Withdrawals
  Tests.Api.Service.Transfer Through The Service
  ```

- `discover files` does not list `tests/archive/legacy.robot`.

## 🔑 Takeaway

**Model each dimension as a small profile and combine them — never maintain a matrix of copies.**
