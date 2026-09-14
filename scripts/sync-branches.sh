#!/usr/bin/env bash
# Propagate fixes: merge main into every topic/* branch, and every topic/NN into its solution/NN.
# Maintainer tool:  scripts/sync-branches.sh [--push]
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
[ -z "$(git status --porcelain)" ] || { echo "Working tree is not clean — commit or stash first." >&2; exit 1; }

start="$(git symbolic-ref --short HEAD)"
push="${1:-}"
trap 'git switch --quiet "$start" 2>/dev/null || true' EXIT

merge() { # target, source
  git switch --quiet "$1"
  if git merge --quiet --no-edit "$2"; then
    echo "merged $2 → $1"
  else
    echo "CONFLICT merging $2 into $1 — resolve it, commit, and run this script again." >&2
    trap - EXIT
    exit 1
  fi
}

for topic in $(git for-each-ref --format='%(refname:short)' 'refs/heads/topic/*'); do
  merge "$topic" main
  solution="solution/${topic#topic/}"
  if git show-ref --verify --quiet "refs/heads/$solution"; then
    merge "$solution" "$topic"
  fi
done

if [ "$push" = "--push" ]; then
  git push origin main 'refs/heads/topic/*:refs/heads/topic/*' 'refs/heads/solution/*:refs/heads/solution/*'
fi
