# Zeedots

```text
 ███████████                       █████           █████           
░█░░░░░░███                       ░░███           ░░███            
░     ███░    ██████   ██████   ███████   ██████  ███████    █████ 
     ███     ███░░███ ███░░███ ███░░███  ███░░███░░░███░    ███░░  
    ███     ░███████ ░███████ ░███ ░███ ░███ ░███  ░███    ░░█████ 
  ████     █░███░░░  ░███░░░  ░███ ░███ ░███ ░███  ░███ ███ ░░░░███
 ███████████░░██████ ░░██████ ░░████████░░██████   ░░█████  ██████ 
░░░░░░░░░░░  ░░░░░░   ░░░░░░   ░░░░░░░░  ░░░░░░     ░░░░░  ░░░░░░  
```

This repository contains Zeedots, the configuration files and scripts I use to customize my development environment. These files help me maintain a consistent setup across different machines and save time when setting up new environments.

> Shout-out to [Hendrik](https://github.com/hendrikmi) and [Josean Martinez](https://github.com/josean-dev) for inspiring large parts of this setup and documentation.

## Essential Tools

- **Editor**: [NeoVim](https://neovim.io/) with a curated plugin set and Lazy config under `configs/config/nvim`. A lightweight [Vim](https://www.vim.org/) profile lives alongside it for portability.
- **Terminals**: [WezTerm](https://wezfurlong.org/wezterm/index.html) is the daily driver, while a full [Kitty](https://sw.kovidgoyal.net/kitty/) profile ships in `configs/config/kitty` for GPU-accelerated sessions.
- **Multiplexer**: [Tmux](https://github.com/tmux/tmux/wiki) with shortcuts, theming, and plugins managed via `configs/config/tmux`.
- **Shell Experience**: [Zsh](https://www.zsh.org/) plus [Starship](https://starship.rs/) prompt, aliases, and completions in `configs/config/zsh` and `configs/config/starship`.
- **Color Theme**: All themes are based on the [Nord color palette](https://www.nordtheme.com/docs/colors-and-palettes). Themes can be easily switched via environment variables set in `.zshenv`.
- **Window Management**: [Rectangle](https://github.com/rxhanson/Rectangle) for resizing windows, paired with [Karabiner-Elements](https://karabiner-elements.pqrs.org/) for switching between applications. Configs are provisioned under `configs/symlinks/rectangle` and `configs/config/karabiner`.
- **File Manager**: [Ranger](https://github.com/ranger/ranger) with preview scripts and bookmarks stored in `configs/config/ranger`.

### Additional Managed Tooling

Beyond the core workflow, Zeedots installs and maintains:

- **AI & IDE Enhancements**: Configs for [Cursor](https://cursor.sh/) (`configs/cursor`), Claude desktop (`configs/claude`), and LM Studio (`configs/lmstudio`) are symlinked from `scripts/symlinks/stow-packages.conf`.
- **Knowledge & Docs**: Obsidian vault preferences (`configs/obsidian`) and Storybook settings (`configs/storybook`) ensure documentation stays synced.
- **Data & Cloud**: DBeaver profiles (`configs/dbeaver`), Docker daemon defaults (`configs/docker`), and Kubernetes contexts (`configs/kube`) land in place during install alongside tight SSH integration (`configs/ssh/1Password`).
- **Automation**: `scripts/homebrew/Brewfile` orchestrates an extensive suite of CLI tools, GUI apps, and VS Code extensions so fresh machines match the primary workstation.

## Custom Window Management

I'm not a fan of the default window management solutions that macOS provides, like repeatedly pressing Cmd+Tab to switch apps or using the mouse to click and drag. To streamline my workflow, I created a custom window management solution using [Karabiner-Elements](https://karabiner-elements.pqrs.org/) and [Rectangle](https://rectangleapp.com/). By using these tools together, I can efficiently manage my windows and switch apps with minimal mental overhead and maximum speed, using only my keyboard. Here's how it works:

### Tab Key as Hyperkey

The `Tab` key acts as a regular `Tab` when tapped, but when held, it provides additional functionalities.

### Access Window Layer

Holding `Tab + W` enables a window management layer, where other keys become shortcuts to resize the current window using Rectangle.

**Examples:**

- `Tab + W + H`: Resize window to the left half
- `Tab + W + L`: Resize window to the right half

### Access Exposé Layer

Holding `Tab + E` enables an exposé layer, where other keys become shortcuts to open specific apps.

**Examples:**

- `Tab + E + J`: Open browser
- `Tab + E + K`: Open terminal

## Setup

To set up Zeedots on your system, run:

```bash
./install.zsh
```

The installer will:

- Prompt for the directory where configuration files should live (defaults to `~/zeedots`) and expose it through the `ZEEDOTS_ROOT` environment variable.
- Copy the `configs/` tree into that directory (see `scripts/install_configs.zsh` for details).
- Create manual symlinks listed in `scripts/symlinks/symlinks.conf`.
- Apply GNU Stow packages defined in `scripts/symlinks/stow-packages.conf` from the chosen root.

You can re-run the symlink step at any time:

```bash
ZEEDOTS_ROOT=~/zeedots ./scripts/symlinks.zsh --create
```

If you installed the configs elsewhere, replace `~/zeedots` with your custom path or pass `--root /custom/path`.

### Linting & Validation

- Run `zsh -n scripts/*.zsh` to ensure shell scripts parse cleanly before executing installs.
- Use `shellcheck` (installed via the Brewfile) for deeper shell diagnostics if Homebrew dependencies are available.
- Validate Neovim configuration with `stylua --check configs/config/nvim` or `luac -p` to confirm Lua syntax.

## Symlink Configuration

- `scripts/symlinks/symlinks.conf` contains explicit `source:target` entries for paths that cannot be managed by Stow (for example items under `~/Library`).
- `scripts/symlinks/stow-packages.conf` lists the Stow packages that will be applied from `ZEEDOTS_ROOT`. Each entry should match a directory inside the root (e.g. `.config`, `.zsh`).

To inspect what Stow will do, run:

```bash
ZEEDOTS_ROOT=~/zeedots stow --dir "$ZEEDOTS_ROOT" --target "$HOME" --verbose --simulate $(cat scripts/symlinks/stow-packages.conf | tr '\n' ' ')
```

## Uninstalling

To remove the symlinks that were created during setup, run:

```bash
ZEEDOTS_ROOT=~/zeedots ./scripts/symlinks.zsh --delete
```

Add `--include-files` if you also want to delete regular files listed in `symlinks.conf` alongside their symlinks. Stow only removes the symlinks it created; the copied configuration directory remains intact so you can reinstall later.

## Adding New Zeedots Components and Software

### Zeedots Files

When adding new Zeedots files to this repository, follow these steps:

1. Place your Zeedots file in the appropriate location within the repository.
2. Update the `symlinks.conf` file to include the symlink creation for your new Zeedots file.
3. If necessary, update the `install.zsh` script to set up the software.

### Software Installation

Software is installed using Homebrew. To add a formula or cask, update the `homebrew/Brewfile` and run `./scripts/brew_install_custom.sh`. If you need to install a specific version of a package, find its Ruby script in the commit history of an official Homebrew GitHub repository and place it in the `homebrew/custom-casks/` or `homebrew/custom-formulae/` directory, depending on whether it's a cask or formula.
