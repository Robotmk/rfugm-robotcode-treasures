# Solution — Chapter 2

## Profiles instead of a matrix

`robot.toml` holds one small profile per option — `local`, `service`, `smoke`, `regression`, `ci` — plus the named
combination `nightly`:

```toml
[profiles.nightly]
description = "Nightly run: regression against the service with CI output, without flaky tests"
inherits = ["service", "regression", "ci"]
extend-excludes = ["flaky"]
```

`.vscode/launch.json` is gone; `.gitlab-ci.yml` and `docs/running-tests.md` only name profiles
(`robotcode -p service -p regression -p ci robot`). The port change request is now one line in `[profiles.service]`.

```bash
robotcode -p nightly profiles show
```

```toml
console = "dotted"
excludes = [
    "wip",
    "flaky",
]
includes = [
    "regression",
]
output-dir = "results/ci"
xunit = "xunit.xml"

[variables]
BANK_URL = "http://localhost:8765"
```

`robotcode -p nightly discover tests` lists six tests (see the self-check in `TOPIC.md`).

### Why `extend-excludes` and not `excludes`

`excludes = ["flaky"]` in `nightly` **replaces** the list inherited from `ci`, so `wip` is no longer excluded and
`Monthly Interest Is Credited` sneaks back in (seven tests). `extend-excludes` appends to the inherited list.

## `.robotignore`

```gitignore
tests/archive/
```

`robotcode discover files` no longer lists `tests/archive/legacy.robot`; the analyzer, the Test Explorer and
`robotcode robot` skip it as well. Remember: with a root `.robotignore`, RobotCode ignores `.gitignore` entirely.

## Bonus

```toml
default-profiles = ["local", "smoke"]

[profiles.ci]
# …
enabled = { if = 'environ.get("CI") == "true"' }
```

- Without `CI=true`, `ci` is disabled — and a disabled profile contributes **nothing** to profiles that inherit it.
  `nightly` loses the `wip` exclusion, the CI output folder and the xUnit file, so seven tests are selected locally.
  With `CI=true robotcode -p nightly discover tests` it is six again.
- Without `-p`, `robotcode discover tests` now lists only the four smoke tests.
