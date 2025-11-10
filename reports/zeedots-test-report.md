## Zeedots Non-Destructive Test Report

Generated: 2025-11-10  
Sandbox root: `/tmp/zeedots-test-ULvRgFku`

### Environment Snapshot
- macOS 26.1 (25B78), `zsh 5.9`
- Key tooling available: `brew`, `stow`, `shellcheck`, `stylua`, `luac`, `yq`, `jq`, `plutil`
- Limitations: Homebrew network requests blocked by missing CA bundle inside sandbox; installer commands stubbed via `$SANDBOX_DIR/bin` to avoid host mutations.

### Executive Summary
- **Critical**: `install.zsh` fails `zsh -n` due to a malformed `if command stow ... then` clause; installation aborts before symlink stages (`reports/logs/zsh_syntax.log`).
- **Critical**: `scripts/symlinks.zsh` sources `utils.sh` (does not exist) and `install.zsh` invokes `./scripts/symlinks.sh`; both typos stop symlink management during installs (`reports/logs/install_simulation.log`).
- **Major**: `install_configs` cannot rename the `cursor` directory to `.cursor`, leaving Stow packages misaligned; `.zshenv`, `.zshrc`, `.profile`, `.gitconfig` packages are absent from `configs/` (`reports/logs/install_simulation.log`, `reports/logs/stow_package_audit.log`).
- **Major**: `brew bundle check` could not complete because the sandbox lacks trusted certificates; dependency drift status remains unknown (`reports/logs/brew_bundle_check.log`).
- **Minor**: `stylua --check` flagged whitespace/style drift in several Lua modules (`reports/logs/stylua_check.log`).
- **Info**: ShellCheck flags (`SC2296`, `SC1091`) stem from zsh-specific parameter expansion and relative sourcing; consider suppressing or reworking for clarity (`reports/logs/shellcheck.log`).

### Test Matrix
All commands executed with `$HOME`, `ZEEDOTS_ROOT`, and `XDG_CONFIG_HOME` redirected to the sandbox.

| Check | Command | Result | Log |
| --- | --- | --- | --- |
| Zsh syntax | `zsh -n install.zsh scripts/*.zsh` | Failed on `install.zsh` | `reports/logs/zsh_syntax.log` |
| ShellCheck | `shellcheck --shell=bash --severity=style …` | Errors on zsh-specific constructs | `reports/logs/shellcheck.log` |
| Lua formatting | `stylua --check configs/config/nvim` | Diff detected | `reports/logs/stylua_check.log` |
| Lua syntax | `luac -p` over Lua files | Pass | `reports/logs/luac_check.log` |
| YAML lint | `yq eval` | Pass | `reports/logs/yaml_check.log` |
| JSON lint | `jq empty` | Pass | `reports/logs/json_check.log` |
| Prerequisite flow | Sourced with stubbed commands | Pass (duplicate auto-run noted) | `reports/logs/prerequisites_simulation.log` |
| Custom Brew flow | Sourced with stubbed `brew` | Pass (auto-run loop, prompt unscripted) | `reports/logs/brew_install_simulation.log` |
| Brew bundle check | `brew bundle check --no-upgrade` | Blocked (TLS cert error) | `reports/logs/brew_bundle_check.log` |
| Stow simulate | `stow --simulate` | Blocked (missing packages) | `reports/logs/stow_simulate.log` |
| Symlink config scan | Parsed `symlinks.conf` | All sources present | `reports/logs/symlink_validation.log` |
| Stow source audit | Compare packages vs `configs/` | Missing `.zshenv`, `.zshrc`, `.profile`, `.gitconfig` | `reports/logs/stow_package_audit.log` |
| Installer dry-run | `install.zsh` with scripted answers, shims | Fails at symlink stage, `.cursor` rename blocked | `reports/logs/install_simulation.log` |

### Detailed Findings
1. ```63:68:install.zsh
    if command stow --dir="$target_root" --target="$HOME" --restow  then
            success "Stowed"
    else
            error "Failed to Stow"
    fi
   ```
   - Missing semicolon or newline before `then`; `zsh -n` raises a parse error, preventing configuration deployment.
2. ```8:14:scripts/symlinks.zsh
source "$SCRIPT_DIR/utils.sh"
```
   - File is actually `scripts/utils.zsh`; runtime `source` fails, so no symlinks are created.
3. ```69:74:install.zsh
    warning "Deleting existing dotfiles..."
    ./scripts/symlinks.sh --delete --include-files
    info "Creating symbolic links..."
    ./scripts/symlinks.sh --create
```
   - Script name mismatch (`.sh` vs `.zsh`) leads to command-not-found during installs.
4. `install_configs` repeatedly fails `mv …/cursor …/.cursor` with `Operation not permitted`, leaving `cursor/` unhidden and forcing Stow errors; root cause may be existing `.cursor` symlink expectations or sandbox attribute restrictions.
5. Stow package audit shows missing source assets for `.zshenv`, `.zshrc`, `.profile`, `.gitconfig`; installer references these packages but repository lacks the corresponding files.
6. `brew bundle check` could not validate dependencies because CA certificates were unavailable inside the sandbox. Further verification on a host with system trust store is required.
7. Stylua diff indicates only spacing inconsistencies; functional Lua syntax validated via `luac -p`.
8. Both `scripts/prerequisites.zsh` and `scripts/brew-install-custom.zsh` auto-execute when sourced, causing duplicate log entries during simulations. Wrap end-of-file invocations with guards or convert to CLI entrypoints.

### Recommendations
- Fix the `if command stow …` syntax and script name typos before executing installers.
- Update `scripts/symlinks.zsh` to source `utils.zsh`.
- Investigate why `mv cursor -> .cursor` fails (permissions, existing destination) and ensure all declared Stow packages have matching assets (`zshenv`, `zshrc`, etc.).
- Re-run `brew bundle check` on a system with proper certificate trust to confirm package coverage; consider bundling CA path configuration for sandboxed executions.
- Apply `stylua` formatting to the flagged Lua modules or document intentional deviations.
- Add `setopt EXTENDED_GLOB` or ShellCheck directives (`# shellcheck shell=bash`) to minimize false alarms, or add a README note about zsh-specific constructs.
- Consider turning the helper scripts into CLI entrypoints (`zmodload zsh/regex` etc.) to avoid implicit execution when sourced for testing.

### Artifacts
- Logs: `reports/logs/*.log` as referenced above.
- Sandbox cleanup: remove `/tmp/zeedots-test-ULvRgFku` when finished (`rm -rf`).

