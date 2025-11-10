#!/bin/zsh

SCRIPT_PATH="${(%):-%N}"
[[ "$SCRIPT_PATH" == "zsh" ]] && SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH:A}"
SCRIPT_DIR="${SCRIPT_PATH:h}"

. "$SCRIPT_DIR/utils.zsh"

# Paths to the custom formulae and casks directories
FORMULAE_DIR="$SCRIPT_DIR/homebrew/custom-formulae"
CASKS_DIR="$SCRIPT_DIR/homebrew/custom-casks"

install_custom() { # Function to install custom formulas and casks
    local package_name="$1"
    local is_cask="$2"

    if [[ "$is_cask" == "true" && -f "$CASKS_DIR/$package_name.rb" ]]; then
        info "Installing custom cask: $package_name"
        brew install --force --cask "$CASKS_DIR/$package_name.rb"
    elif [[ "$is_cask" != "true" && -f "$FORMULAE_DIR/$package_name.rb" ]]; then
        info "Installing custom formula: $package_name"
        brew install "$FORMULAE_DIR/$package_name.rb"
    else
        error "File not found for package: $package_name"
        return 1
    fi
}

install_custom_formulae() {
    local custom_formulae=()
    if [[ -d "$FORMULAE_DIR" ]]; then
        for file in "$FORMULAE_DIR"/*.rb; do
            [[ -e "$file" ]] || continue
            custom_formulae+=("$(basename "${file%.rb}")")
        done
    fi

    for formula in "${custom_formulae[@]}"; do
        install_custom "$formula" "false"
    done
}

install_custom_casks() {
    local custom_casks=()
    if [[ -d "$CASKS_DIR" ]]; then
        for file in "$CASKS_DIR"/*.rb; do
            [[ -e "$file" ]] || continue
            custom_casks+=("$(basename "${file%.rb}")")
        done
    fi

    for cask in "${custom_casks[@]}"; do
        install_custom "$cask" "true"
    done
}

run_brew_bundle() {
    local brewfile="$SCRIPT_DIR/homebrew/Brewfile"
    if [[ -f "$brewfile" ]]; then
        local check_output
        check_output=$(brew bundle check --file="$brewfile" 2>&1)

        if echo "$check_output" | grep -q "The Brewfile's dependencies are satisfied."; then
            warning "The Brewfile's dependencies are already satisfied."
        else
            info "Satisfying missing dependencies with 'brew bundle install'..."
            brew bundle install --file="$brewfile"
        fi
    else
        error "Brewfile not found"
        return 1
    fi
}

if [[ "$SCRIPT_PATH" == "${0:A}" ]]; then
    if ! command -v brew &>/dev/null; then
        error "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
    install_custom_formulae
    install_custom_casks

    printf "Install Brew bundle? [y/n] "
    read -r install_bundle

    if [[ "$install_bundle" == "y" ]]; then
        run_brew_bundle
    fi
fi
