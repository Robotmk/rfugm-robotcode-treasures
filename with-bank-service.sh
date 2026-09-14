#!/usr/bin/env bash
# Starts the bank service, runs the command it is given (the test run), and stops the service again.
# Used as a RobotCode wrapper: robotcode calls  ./with-bank-service.sh <the robot command…>
set -uo pipefail
cd "$(dirname "$0")"

port=8765
if curl -fs "http://localhost:$port/health" >/dev/null; then
  echo "with-bank-service: a bank service is already running on port $port — stop it first" >&2
  exit 1
fi

python3 -m bank.service --port "$port" &
service_pid=$!

# Always stop the service — after passing, failing or aborted runs.
trap 'kill "$service_pid" 2>/dev/null; wait "$service_pid" 2>/dev/null' EXIT

# Wait until the service answers instead of hoping one second is enough.
for _ in $(seq 50); do
  curl -fs "http://localhost:$port/health" >/dev/null && break
  if ! kill -0 "$service_pid" 2>/dev/null; then
    echo "with-bank-service: the bank service could not be started (is port $port already in use?)" >&2
    exit 1
  fi
  sleep 0.1
done
curl -fs "http://localhost:$port/health" >/dev/null || {
  echo "with-bank-service: the bank service did not answer within 5 seconds" >&2
  exit 1
}

# Run the tests; the script's exit code is the exit code of the test run.
"$@"
