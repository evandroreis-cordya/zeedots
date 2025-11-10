#!/bin/zsh

. scripts/utils.zsh
. scripts/prerequisites.zsh
. scripts/brew-install-custom.zsh
. scripts/osx-defaults.zsh
. scripts/install_configs.zsh
. scripts/symlinks.zsh

info "Dotfiles intallation initialized..."
read -p "Install apps? [y/n] " install_apps
read -p "Overwrite existing dotfiles? [y/n] " overwrite_dotfiles

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "===================="
    info "Prerequisites"
    info "===================="

    install_xcode
    install_homebrew

    printf "\n"
    info "===================="
    info "Apps"
    info "===================="

    install_custom_formulae
    install_custom_casks
    run_brew_bundle
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

printf "\n"
info "===================="
info "Configurations"
info "===================="

install_configs

printf "\n"
info "===================="
info "Symbolic Links"
info "===================="

chmod +x ./scripts/symlinks.zsh
if [[ "$overwrite_dotfiles" == "y" ]]; then
    warning "Deleting existing dotfiles..."
    ./scripts/symlinks.zsh --delete --include-files
fi
./scripts/symlinks.zsh --create

success "Dotfiles set up successfully."
