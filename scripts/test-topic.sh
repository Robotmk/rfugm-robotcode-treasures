#!/usr/bin/env bash
# Tests for ./topic in a throw-away repository cloned from a bare "origin".
# Maintainer tool:  scripts/test-topic.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export TOPIC_NO_OPEN=1 GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

failures=0
check() { # description, command...
  local description="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "ok   - $description"; else echo "FAIL - $description"; failures=$((failures + 1)); fi
}
branch() { git -C "$TMP/work" symbolic-ref --short HEAD; }

# --- build the source repository ------------------------------------------------------------
git init -q -b main "$TMP/src"
cd "$TMP/src"
cp "$ROOT/topic" . && printf '.venv/\n' > .gitignore && echo "base" > README.md
git add . && git commit -qm main
git switch -qc topic/01-alpha && printf '# Chapter 1 — Alpha\n' > TOPIC.md && echo "start" > a.txt
git add . && git commit -qm topic1
git switch -qc solution/01-alpha && echo "solved" > a.txt && git commit -qam solution1
git switch -q main && git switch -qc topic/02-beta && printf '# Chapter 2 — Beta\n' > TOPIC.md
git add . && git commit -qm topic2
git switch -q main
git clone -q --bare "$TMP/src" "$TMP/origin.git"
git clone -q "$TMP/origin.git" "$TMP/work"
cd "$TMP/work"

# --- tests ------------------------------------------------------------------------------------
list="$(./topic)"
check "list shows chapter 1 with title" grep -q "01.*Alpha" <<<"$list"
check "list shows chapter 2 with title" grep -q "02.*Beta" <<<"$list"

./topic 1 >/dev/null
check "switch to a remote-only chapter" test "$(branch)" = topic/01-alpha

echo "my change" >> a.txt && echo "new" > mine.txt
./topic 02 >/dev/null
check "switch away with local changes" test "$(branch)" = topic/02-beta
check "own changes are not carried over" test ! -e mine.txt

./topic 01 >/dev/null
check "tracked change is restored" grep -q "my change" a.txt
check "untracked file is restored" test -f mine.txt
check "autosave stash is consumed" test -z "$(git stash list)"

check "check shows a diff against the solution" bash -c './topic check | grep -q solved'

echo y | ./topic reset >/dev/null
check "reset discards tracked changes" test "$(cat a.txt)" = start
check "reset removes untracked files" test ! -e mine.txt

./topic 1 --solution >/dev/null
check "switch to solution" test "$(branch)" = solution/01-alpha

./topic main >/dev/null
check "switch back to main" test "$(branch)" = main

check "unknown chapter fails" bash -c '! ./topic 42'

check "runs when started with sh" bash -c 'sh ./topic 2 && test "$(git symbolic-ref --short HEAD)" = topic/02-beta'

# Interactive menu, driven through a pseudo-terminal.
tty_run() { # keys
  if script --version >/dev/null 2>&1; then          # util-linux (Linux, Codespaces)
    printf "$1" | TERM=xterm script -qec "./topic" /dev/null >/dev/null 2>&1
  else                                               # BSD (macOS)
    printf "$1" | TERM=xterm script -q /dev/null ./topic >/dev/null 2>&1
  fi
}
./topic main >/dev/null
tty_run '\033[B\r'
check "menu: arrow down + Enter opens chapter 1" test "$(branch)" = topic/01-alpha
tty_run 's'
check "menu: s opens the solution of the selected chapter" test "$(branch)" = solution/01-alpha
tty_run '2\r'
check "menu: digit + Enter jumps to a chapter" test "$(branch)" = topic/02-beta
tty_run '\033[A\033[A\rq'
check "menu: arrow up + Enter opens main" test "$(branch)" = main
tty_run 'q'
check "menu: q changes nothing" test "$(branch)" = main

echo
if [ "$failures" -eq 0 ]; then echo "All tests passed."; else echo "$failures test(s) failed."; exit 1; fi
