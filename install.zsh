#!/bin/zsh

. scripts/utils.zsh
. scripts/prerequisites.zsh
. scripts/brew-install-custom.zsh
. scripts/osx-defaults.zsh
. scripts/install_configs.zsh
. scripts/symlinks.zsh

info "Zeedots installation initialized..."
read -p "Install apps? [y/n] " install_apps
read -p "Overwrite existing Zeedots files? [y/n] " overwrite_zeedots

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
if [[ "$overwrite_zeedots" == "y" ]]; then
    warning "Deleting existing Zeedots files..."
    ./scripts/symlinks.zsh --delete --include-files
fi
./scripts/symlinks.zsh --create

success "Zeedots set up successfully."
