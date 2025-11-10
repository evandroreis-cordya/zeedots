# Zeedots

This repository contains Zeedots, the configuration files and scripts I use to customize my development environment. These files help me maintain a consistent setup across different machines and save time when setting up new environments.

## Essential Tools

- **Editor**: [NeoVim](https://neovim.io/). As a fallback, I have a basic standard [Vim](https://www.vim.org/) config that provides 80% of the functionality of my NeoVim setup without any dependencies for maximum portability and stability.
- **Multiplexer**: [Tmux](https://github.com/tmux/tmux/wiki)
- **Main Terminal**: [WezTerm](https://wezfurlong.org/wezterm/index.html)
- **Shell Prompt**: [Starship](https://starship.rs/)
- **Color Theme**: All themes are based on the [Nord color palette](https://www.nordtheme.com/docs/colors-and-palettes). Themes can be easily switched via environment variables set in `.zshenv`.
- **Window Management**: [Rectangle](https://github.com/rxhanson/Rectangle) for resizing windows, paired with [Karabiner-Elements](https://karabiner-elements.pqrs.org/) for switching between applications.
- **File Manager**: [Ranger](https://github.com/ranger/ranger)

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

- Prompt for the directory where configuration files should live (defaults to `~/dots`) and expose it through the `ZEEDOTS_ROOT` environment variable.
- Copy the `configs/` tree into that directory (see `scripts/install_configs.zsh` for details).
- Create manual symlinks listed in `scripts/symlinks/symlinks.conf`.
- Apply GNU Stow packages defined in `scripts/symlinks/stow-packages.conf` from the chosen root.

You can re-run the symlink step at any time:

```bash
ZEEDOTS_ROOT=~/dots ./scripts/symlinks.zsh --create
```

If you installed the configs elsewhere, replace `~/dots` with your custom path or pass `--root /custom/path`.

## Symlink Configuration

- `scripts/symlinks/symlinks.conf` contains explicit `source:target` entries for paths that cannot be managed by Stow (for example items under `~/Library`).
- `scripts/symlinks/stow-packages.conf` lists the Stow packages that will be applied from `ZEEDOTS_ROOT`. Each entry should match a directory inside the root (e.g. `.config`, `.zsh`).

To inspect what Stow will do, run:

```bash
ZEEDOTS_ROOT=~/dots stow --dir "$ZEEDOTS_ROOT" --target "$HOME" --verbose --simulate $(cat scripts/symlinks/stow-packages.conf | tr '\n' ' ')
```

## Uninstalling

To remove the symlinks that were created during setup, run:

```bash
ZEEDOTS_ROOT=~/dots ./scripts/symlinks.zsh --delete
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
