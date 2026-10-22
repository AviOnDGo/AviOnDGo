#!/usr/bin/env bash
set -euo pipefail

pattern="(password|passwd|secret|token|api_key|apikey|access_key|private_key|auth_token)[[:space:]]*[=:][[:space:]]*['\"]?[A-Za-z0-9/+_-]{8,}"
repo_root="$(git rev-parse --show-toplevel)"
allowlist_file="$repo_root/.secretscan-allowlist"

if git -C "$repo_root" rev-parse --verify --quiet '@{u}' >/dev/null; then
  commit_range="@{u}..HEAD"
else
  base_ref="$(git -C "$repo_root" show-ref --verify --quiet refs/heads/main && printf main || printf master)"
  merge_base="$(git -C "$repo_root" merge-base HEAD "$base_ref")"
  commit_range="$merge_base..HEAD"
fi

added_lines="$(git -C "$repo_root" log "$commit_range" --format=%H | while IFS= read -r commit; do git -C "$repo_root" show --format= "$commit"; done | grep -E '^\+[^+]' || true)"
matches="$(printf '%s\n' "$added_lines" | grep -En "$pattern" || true)"
if [[ -n "$matches" && -f "$allowlist_file" ]]; then
  matches="$(printf '%s\n' "$matches" | grep -Evf "$allowlist_file" || true)"
fi

if [[ -n "$matches" ]]; then
  echo "Secret scan failed for push range ($commit_range)."
  echo "Potential secrets found:"
  printf '%s\n' "$matches"
  echo
  echo "Rewrite or amend commits before push, or add a reviewed false-positive regex to $allowlist_file."
  exit 1
fi

echo "Secret scan passed for push range ($commit_range)."