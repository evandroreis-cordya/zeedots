#!/bin/zsh

SCRIPT_PATH="${(%):-%N}"
[[ "$SCRIPT_PATH" == "zsh" ]] && SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH:A}"
SCRIPT_DIR="${SCRIPT_PATH:h}"

. "$SCRIPT_DIR/utils.zsh"

install_xcode() {
    info "Installing Apple's CLI tools (prerequisites for Git and Homebrew)..."
    if xcode-select -p >/dev/null; then
        warning "xcode is already installed"
    else
        xcode-select --install
        sudo xcodebuild -license accept
    fi
}

install_homebrew() {
    info "Installing Homebrew..."
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    if hash brew &>/dev/null; then
        warning "Homebrew already installed"
    else
        sudo --validate
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
}

install_stow() {
    info "Installing GNU Stow..."
    if ! hash brew &>/dev/null; then
        error "Homebrew not available; cannot install GNU Stow"
        return 1
    fi

    if brew list stow &>/dev/null; then
        warning "GNU Stow already installed"
    else
        brew install stow
    fi
}

if [[ "$SCRIPT_PATH" == "${0:A}" ]]; then
    install_xcode
    install_homebrew
    install_stow
fi
