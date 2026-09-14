#!/usr/bin/env bash
# Tests for scripts/sync-branches.sh with a bare "origin", an authoring clone and a "Codespace" clone.
# Maintainer tool:  scripts/test-sync.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

failures=0
check() { # description, command...
  local description="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "ok   - $description"; else echo "FAIL - $description"; failures=$((failures + 1)); fi
}
remote_file() { git -C "$TMP/origin.git" show "$1" 2>/dev/null; }

# --- origin with main, one chapter and its solution -------------------------------------------
git init -q -b main "$TMP/seed"
cd "$TMP/seed"
mkdir scripts && cp "$ROOT/scripts/sync-branches.sh" scripts/
printf 'line 1\nline 2\nline 3\n' > shared.txt && git add . && git commit -qm main
git switch -qc topic/01-a && printf 'topic text\n' > TOPIC.md && git add . && git commit -qm topic
git switch -qc solution/01-a && printf 'solution\n' > SOLUTION.md && git add . && git commit -qm solution
git switch -q main
git clone -q --bare "$TMP/seed" "$TMP/origin.git"
git clone -q "$TMP/origin.git" "$TMP/author"
git clone -q "$TMP/origin.git" "$TMP/codespace"
( cd "$TMP/author" && for b in topic/01-a solution/01-a; do git branch -q --track "$b" "origin/$b"; done )

# --- a fix pushed from the Codespace, a change made in the authoring clone ---------------------
(
  cd "$TMP/codespace"
  git switch -q topic/01-a && printf 'topic text  \n' > TOPIC.md && git commit -qam "fix from codespace" && git push -q origin topic/01-a
)
cd "$TMP/author"
sed -i.bak 's/line 1/line 1 (edited)/' shared.txt && rm shared.txt.bak && git commit -qam "edit on main"

output="$(scripts/sync-branches.sh --push 2>&1)" && status=0 || status=$?
check "sync succeeds with diverged branches" test "$status" -eq 0
check "codespace commit is merged into the local topic branch" bash -c 'git show topic/01-a:TOPIC.md | grep -q "topic text  "'
check "main is merged into the topic branch" bash -c 'git show topic/01-a:shared.txt | grep -q "(edited)"'
check "topic reaches the solution branch" bash -c 'git show solution/01-a:TOPIC.md | grep -q "topic text  " && git show solution/01-a:shared.txt | grep -q "(edited)"'
check "origin has the merged topic branch" bash -c "git -C '$TMP/origin.git' show topic/01-a:shared.txt | grep -q '(edited)'"
check "origin keeps the codespace commit" bash -c "git -C '$TMP/origin.git' log --format=%s topic/01-a | grep -q 'fix from codespace'"
check "origin has the updated solution" bash -c "git -C '$TMP/origin.git' show solution/01-a:shared.txt | grep -q '(edited)'"
check "script returns to the starting branch" test "$(git symbolic-ref --short HEAD)" = main

# --- a new chapter created on GitHub only -----------------------------------------------------
( cd "$TMP/codespace" && git fetch -q && git switch -qc topic/02-b origin/main && echo b > TOPIC.md && git add . && git commit -qm "topic 2" && git push -q origin topic/02-b )
scripts/sync-branches.sh >/dev/null 2>&1
check "branch that exists only on origin is created locally" git show-ref --verify --quiet refs/heads/topic/02-b

# --- a real conflict stops before anything is pushed -----------------------------------------
(
  cd "$TMP/codespace"
  git fetch -q && git switch -q main && git merge -q --ff-only origin/main
  sed -i.bak 's/line 2/line 2 from codespace/' shared.txt && rm shared.txt.bak && git commit -qam "codespace edit" && git push -q origin main
)
sed -i.bak 's/line 2/line 2 from author/' shared.txt && rm shared.txt.bak && git commit -qam "author edit"
git switch -q topic/01-a && echo "local topic change" > NOTE.md && git add NOTE.md && git commit -qm "topic change" && git switch -q main
output="$(scripts/sync-branches.sh --push 2>&1)" && status=0 || status=$?
check "conflict makes the script fail" test "$status" -ne 0
check "conflict is reported with the branch name" grep -q "CONFLICT.*origin/main.*main" <<<"$output"
check "nothing is pushed after a conflict" bash -c "! git -C '$TMP/origin.git' show topic/01-a:NOTE.md"
git merge --abort 2>/dev/null || true

echo
if [ "$failures" -eq 0 ]; then echo "All tests passed."; else echo "$failures test(s) failed."; exit 1; fi
