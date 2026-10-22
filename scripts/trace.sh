#!/usr/bin/env bash
# Traceability check: spec acceptance criteria -> tests -> PR.
# Usage: regulations/scripts/trace.sh [specs_dir] [pr_body_file]
# Run from the project repo root. Exit 1 on any broken link. Zero AI tokens.
set -euo pipefail

SPECS_DIR="${1:-docs/specs}"
PR_BODY="${2:-}"
ID_PATTERN='AC-[a-z0-9]+(-[a-z0-9]+)*'
CRITERION_LINE='^- \[[ x]\] '
DONE_LINE='^- \[x\] '

errors=0
fail() {
  echo "FAIL: $*" >&2
  errors=$((errors + 1))
}

if [ ! -d "$SPECS_DIR" ]; then
  echo "No specs dir '$SPECS_DIR': nothing to trace." >&2
  exit 0
fi

# 1. Every acceptance criterion carries an ID.
while IFS= read -r line; do
  fail "criterion without ID: $line"
done < <(grep -rnE "$CRITERION_LINE" "$SPECS_DIR" --include='*.md' | grep -vE "$ID_PATTERN" || true)

# 2. IDs are unique across all specs.
all_ids=$(grep -rhoE "$ID_PATTERN" "$SPECS_DIR" --include='*.md' | sort || true)
while IFS= read -r dup; do
  [ -n "$dup" ] && fail "ID defined more than once: $dup"
done < <(echo "$all_ids" | uniq -d)

# 3. Every ticked criterion is referenced outside docs (by a test name or comment).
done_ids=$(grep -rhE "$DONE_LINE" "$SPECS_DIR" --include='*.md' | grep -oE "$ID_PATTERN" | sort -u || true)
for id in $done_ids; do
  if ! git grep -qwF -- "$id" -- ":!$SPECS_DIR" ':!docs' ':!regulations'; then
    fail "$id is ticked done but no test references it"
  fi
done

# 4. The PR cites at least one ID, and every ID it cites exists.
if [ -n "$PR_BODY" ]; then
  cited=$(grep -oE "$ID_PATTERN" "$PR_BODY" | sort -u || true)
  [ -z "$cited" ] && fail "PR body cites no acceptance criterion ID"
  for id in $cited; do
    echo "$all_ids" | grep -qxF -- "$id" || fail "PR cites unknown ID: $id"
  done
fi

if [ "$errors" -gt 0 ]; then
  echo "trace: $errors problem(s)." >&2
  exit 1
fi
echo "trace: ok"
