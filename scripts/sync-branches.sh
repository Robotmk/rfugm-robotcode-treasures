#!/usr/bin/env bash
# Propagate fixes: merge main into every topic/* branch, and every topic/NN into its solution/NN.
# Commits that were pushed to GitHub in the meantime (e.g. from a Codespace) are merged in first.
# Maintainer tool:  scripts/sync-branches.sh [--push]
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
[ -z "$(git status --porcelain)" ] || { echo "Working tree is not clean — commit or stash first." >&2; exit 1; }

start="$(git symbolic-ref --short HEAD)"
push="${1:-}"
trap 'git switch --quiet "$start" 2>/dev/null || true' EXIT

merge() { # target, source
  local before
  git switch --quiet "$1"
  before="$(git rev-parse HEAD)"
  if git merge --quiet --no-edit "$2" >/dev/null; then
    [ "$(git rev-parse HEAD)" = "$before" ] || echo "merged $2 → $1"
  else
    echo "CONFLICT merging $2 into $1 — resolve it, commit, and run this script again." >&2
    echo "Nothing has been pushed." >&2
    trap - EXIT
    exit 1
  fi
}

workshop_branches() { # main, topic/*, solution/* — local ones
  git for-each-ref --format='%(refname:short)' refs/heads/main 'refs/heads/topic/*' 'refs/heads/solution/*'
}

# 1. Take over what was pushed to GitHub in the meantime.
if git remote get-url origin >/dev/null 2>&1; then
  echo "Fetching origin …"
  git fetch --quiet --prune origin
  for branch in $(git for-each-ref --format='%(refname:lstrip=3)' refs/remotes/origin/main 'refs/remotes/origin/topic/*' 'refs/remotes/origin/solution/*'); do
    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
      git branch --quiet "$branch" "origin/$branch"
      echo "created $branch from origin"
    fi
  done
  for branch in $(workshop_branches); do
    if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      merge "$branch" "origin/$branch"
    fi
  done
fi

# 2. Merge downwards: main → topic/NN → solution/NN.
for topic in $(git for-each-ref --format='%(refname:short)' 'refs/heads/topic/*'); do
  merge "$topic" main
  solution="solution/${topic#topic/}"
  if git show-ref --verify --quiet "refs/heads/$solution"; then
    merge "$solution" "$topic"
  fi
done

# 3. Publish everything at once — either all branches are updated on GitHub or none.
if [ "$push" = "--push" ]; then
  git push --atomic origin $(workshop_branches | sed 's#.*#refs/heads/&:refs/heads/&#')
fi
echo "Done."
