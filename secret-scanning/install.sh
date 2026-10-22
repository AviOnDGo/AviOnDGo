#!/usr/bin/env bash
set -euo pipefail

shared_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git rev-parse --show-toplevel)"

if [[ ! -x "$shared_dir/hooks/pre-commit" || ! -x "$shared_dir/hooks/pre-push" ]]; then
  echo "Secret-scanning hook files are missing or not executable." >&2
  exit 1
fi

git -C "$repo_root" config --local core.hooksPath "$shared_dir/hooks"
printf 'Configured Git hooks for %s\n' "$repo_root"
printf 'Hook source: %s/hooks\n' "$shared_dir"