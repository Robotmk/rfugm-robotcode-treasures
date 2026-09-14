# Solution — Chapter 5

## `robot.toml`

```toml
[profiles.service]
description = "Run against the bank web service on localhost:8765"
variables = { BANK_URL = "http://localhost:8765" }
wrapper = ["./with-bank-service.sh"]
```

## `with-bank-service.sh`

The key changes compared to the naive version:

1. **No `set -e`** around the test run, so a failing run does not skip the cleanup.
2. **`trap … EXIT`** stops the service however the script ends — pass, fail, `Ctrl+C`, or an error while starting.
3. **`"$@"` is the last command**, so the exit code of the test run is the exit code of the script.
4. Bonus: a guard against an already running service, and polling `/health` instead of `sleep 1`.

See the full script in `with-bank-service.sh`.

## Verified behaviour

```text
$ robotcode -p service robot tests/api
3 tests, 3 passed, 0 failed

$ robotcode -p service robot --variable BANK_URL:http://localhost:9999 tests/api; echo "exit code: $?"
3 tests, 0 passed, 3 failed
exit code: 3

$ curl -fs localhost:8765/health || echo "service stopped"
service stopped

$ python3 -m bank.service &    # something else holds the port
$ robotcode -p service robot tests/api
with-bank-service: a bank service is already running on port 8765 — stop it first
```

`robotcode -p service robot-debug tests/api` and the ▶ / 🐞 buttons in VS Code (profile `service` selected) use the
same wrapper.
