#!/usr/bin/env bash
# Starts the bank service, runs the command it is given (the test run), and stops the service again.
# Used as a RobotCode wrapper: robotcode calls  ./with-bank-service.sh <the robot command…>
set -e
cd "$(dirname "$0")"

python3 -m bank.service --port 8765 &
sleep 1

"$@"

kill %1
