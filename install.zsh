#!/bin/zsh

. scripts/utils.zsh
. scripts/prerequisites.zsh
. scripts/brew-install-custom.zsh
. scripts/osx-defaults.zsh
. scripts/install_configs.zsh
. scripts/symlinks.zsh

info "Zeedots installation initialized..."

local default_root="$HOME/zeedots"
local target_root
target_root="${1:-$default_root}"

read -p "Install apps? [y/n] " install_apps
read -p "Create/Overwrite existing Zeedots files? [y/n] " overwrite_zeedots

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "===================="
    info "Prerequisites"
    info "===================="

    install_xcode
    install_homebrew
    install_stow
    

    printf "\n"
    info "===================="
    info "Apps"
    info "===================="

    install_custom_formulae
    install_custom_casks
    run_brew_bundle
fi

chmod +x ./scripts/install_configs.zsh
chmod +x ./scripts/symlinks.zsh

if [[ "$overwrite_zeedots" == "y" ]]; then
    printf "\n"
    info "===================="
    info "Configurations"
    info "===================="

    read -p "Where should the configurations be installed? [$target_root] " target_root
    if [[ -z "$target_root" ]]; then
        target_root="$default_root"
    fi

    info "Installing configurations to $target_root..."
    
    install_configs "$target_root"  

    if ! command -v stow >/dev/null 2>&1; then
        error "GNU Stow is not installed or not on PATH. Install it (e.g., 'brew install stow')."
        return 1
    fi

    if command stow --dir="$target_root" --target="$HOME" --restow  then
            success "Stowed"
    else
            error "Failed to Stow"
    fi

    warning "Deleting existing dotfiles..."
    ./scripts/symlinks.sh --delete --include-files
    
    info "Creating symbolic links..."
    ./scripts/symlinks.sh --create
fi

printf "\n"
info "===================="
info "OSX System Defaults"
info "===================="

register_keyboard_shortcuts
apply_osx_system_defaults

printf "\n"
info "===================="
info "Terminal"
info "===================="

info "Adding .hushlogin file to suppress 'last login' message in terminal..."
touch ~/.hushlogin

success "Zeedots set up successfully."
