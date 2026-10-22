#!/usr/bin/env bash
set -euo pipefail

pattern="(password|passwd|secret|token|api_key|apikey|access_key|private_key|auth_token)[[:space:]]*[=:][[:space:]]*['\"]?[A-Za-z0-9/+_-]{8,}"
repo_root="$(git rev-parse --show-toplevel)"
allowlist_file="$repo_root/.secretscan-allowlist"

staged_diff="$(git -C "$repo_root" diff --cached -- . ':(exclude)*.example' || true)"
if [[ -z "$staged_diff" ]]; then
  echo "No staged changes to scan."
  exit 0
fi

added_lines="$(printf '%s\n' "$staged_diff" | grep -E '^\+[^+]' || true)"
matches="$(printf '%s\n' "$added_lines" | grep -En "$pattern" || true)"
if [[ -n "$matches" && -f "$allowlist_file" ]]; then
  matches="$(printf '%s\n' "$matches" | grep -Evf "$allowlist_file" || true)"
fi

if [[ -n "$matches" ]]; then
  echo "Secret scan failed for staged changes."
  echo "Potential secrets found:"
  printf '%s\n' "$matches"
  echo
  echo "Resolve findings before commit, or add a narrowly scoped allowlist regex to $allowlist_file if this is a reviewed false positive."
  exit 1
fi

echo "Secret scan passed for staged changes."