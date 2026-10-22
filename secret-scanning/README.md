# Reusable Secret Scanning Hooks

These Bash hooks scan staged changes before commits and outgoing commits before pushes. They run locally and do not replace GitHub Actions secret scanning.

## Add to a Repository

From the root of the consuming repository, add this repository as a submodule. Pin it to a reviewed commit or release tag so hook behavior is reproducible:

```bash
git submodule add https://github.com/AviOnDGo/AviOnDGo.git .tools/AviOnDGo
git -C .tools/AviOnDGo checkout <reviewed-commit-or-tag>
git add .tools/AviOnDGo
```

Initialize the submodule after cloning the consuming repository, then configure local Git hooks:

```bash
git submodule update --init --recursive
bash .tools/AviOnDGo/secret-scanning/install.sh
```

The installer sets `core.hooksPath` in the consuming repository's local Git configuration. Run it once per clone, from the consuming repository root. Developers need Bash and Git; no scanner package installation is required.

## Behavior

- `pre-commit` scans added lines in the staged diff and excludes `*.example` files.
- `pre-push` scans added lines in commits from the configured upstream, or from the merge base with local `main` or `master` when no upstream exists.
- Both scanners read `.secretscan-allowlist` from the consuming repository root. Keep false-positive exceptions local to each repository and narrowly scoped.
- Both hooks fail closed when a match is found.

## Update

Review and pin a newer commit or release tag in the submodule, record the new submodule commit in the consuming repository, and rerun the installer if the submodule path changed. Existing clones use the checked-out version until updated.

## Manual Checks

```bash
bash .tools/AviOnDGo/secret-scanning/scripts/scan-secrets-staged.sh
bash .tools/AviOnDGo/secret-scanning/scripts/scan-secrets-range.sh
```