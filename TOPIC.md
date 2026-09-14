# Chapter 5 — Running tests and the wrapper

> ⏱ 15 minutes · 📚 [Wrapper reference](https://robotcode.io/03_reference/wrapper) · [What's new in 2.7](https://robotcode.io/news/2026-07-15-whats-new-v2.7.0)

## Pain

The integration tests in `tests/api` need the bank web service. So everybody has to remember:

1. start `python3 -m bank.service` in a second terminal,
2. run the tests,
3. stop the service again.

The ▶ button and the debugger in VS Code know nothing about step 1. CI has its own `service &` + `sleep 2` copy.
And when a run crashes, the service keeps running in the background — the next run prints
`Address already in use`, the tests turn green anyway… against a stale service with yesterday's code.

## Treasure

**The wrapper** (new in RobotCode 2.7): the test execution runs *inside* a command of your choice. The command
prepares the environment, runs the tests, and cleans up afterwards.

```toml
[profiles.service]
wrapper = ["./with-bank-service.sh"]
```

- It applies to everything that **executes** Robot Framework through `robotcode`: `robot`, `robot-debug`, the REPL,
  the notebook kernel — and therefore also the ▶ and 🐞 buttons in VS Code. Discovery, analysis and the language
  server are not affected.
- Ad hoc: `robotcode --wrapper ./script.sh …` or `ROBOTCODE_WRAPPER`; switch a configured wrapper off for one run
  with `robotcode --no-wrapper …`. In VS Code, `robotcode.debug.launchWrapper` overrides it for the editor only.
- Only environment variables? Then `[env]` in `robot.toml` is enough — a wrapper is for things that must *run*.

This branch contains `with-bank-service.sh`, a first, deliberately naive version of such a script.

## Demo

1. Without the service, the integration tests fail:

   ```bash
   robotcode -p service robot tests/api        # 3 tests, 0 passed, 3 failed — "does not answer"
   ```

2. Add the wrapper to `[profiles.service]` in `robot.toml`:

   ```toml
   wrapper = ["./with-bank-service.sh"]
   ```

3. Run again — the service starts and stops by itself:

   ```bash
   robotcode -p service robot tests/api        # 3 tests, 3 passed
   curl -fs localhost:8765/health || echo "service stopped"
   ```

4. VS Code: **RobotCode: Select Configuration Profiles** → `service`; run and debug `tests/api/service.robot` from
   the Test Explorer, with a breakpoint in `Transfer Through The Service`.
5. The weak spot — a failing run:

   ```bash
   robotcode -p service robot --variable BANK_URL:http://localhost:9999 tests/api
   curl -fs localhost:8765/health && echo "  <- the service is still running!"
   robotcode -p service robot tests/api        # "Address already in use" … and still green
   pkill -f bank.service                       # clean up by hand
   ```

## Exercise

1. Add the wrapper to the `service` profile (if you have not typed along).
2. Fix `with-bank-service.sh` so that the service is **always** stopped — after passing, failing and aborted runs —
   and the script still exits with the **exit code of the test run** (CI depends on it).

### Bonus

- Replace `sleep 1` by polling `http://localhost:8765/health` until the service answers, with a timeout and a clear
  error message.
- Fail with a helpful message if a bank service is already running on the port.

## Hints

<details><summary>Hint 1 — why the service survives</summary>

`set -e` makes the script exit as soon as `"$@"` returns a non-zero exit code — before it reaches `kill %1`.
</details>

<details><summary>Hint 2 — cleanup that always runs</summary>

Bash runs an `EXIT` trap however the script ends. Remember the process id right after starting the service:

```bash
python3 -m bank.service --port 8765 &
service_pid=$!
trap 'kill "$service_pid"' EXIT
```
</details>

<details><summary>Hint 3 — keeping the exit code</summary>

If `"$@"` is the last command of the script, its exit code becomes the script's exit code — the `EXIT` trap does
not change it. A `kill` *after* `"$@"` would.
</details>

<details><summary>Hint 4 — polling</summary>

`curl -fs http://localhost:8765/health` returns 0 once the service answers. Try it in a loop with `sleep 0.1`.
</details>

## Self-check

```bash
robotcode -p service robot tests/api
robotcode -p service robot --variable BANK_URL:http://localhost:9999 tests/api; echo "exit code: $?"
curl -fs localhost:8765/health || echo "service stopped"
```

- The first run passes: `3 tests, 3 passed, 0 failed`.
- The second run fails with `exit code: 3` (not 0).
- Afterwards: `service stopped`.

## Takeaway

**Put setup and teardown of the test environment into a wrapper — the editor, the terminal and CI all get it for free.**
