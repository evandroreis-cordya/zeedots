#!/bin/zsh

SCRIPT_PATH="${(%):-%N}"
[[ "$SCRIPT_PATH" == "zsh" ]] && SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH:A}"
SCRIPT_DIR="${SCRIPT_PATH:h}"

. "$SCRIPT_DIR/utils.zsh"

install_configs() {
    local default_root="$HOME/zeedots"
    local target_root

    printf "Enter root directory for configuration files [%s]: " "$default_root"
    read -r target_root
    if [[ -z "$target_root" ]]; then
        target_root="$default_root"
    fi

    typeset -gx ZEEDOTS_ROOT="$target_root"

    info "Installing configuration files to $target_root"
    if ! mkdir -p "$target_root"; then
        error "Unable to create or access $target_root"
        return 1
    fi

    local repo_root="${SCRIPT_DIR:h}"
    local configs_source="$repo_root/configs"
    if [[ ! -d "$configs_source" ]]; then
        error "Source directory '$configs_source' not found."
        return 1
    fi

    info "Copying contents from $configs_source to $target_root"
    if ! cp -R "$configs_source/." "$target_root/"; then
        error "Failed to copy configuration files."
        return 1
    fi

    info "Renaming top-level folders to use dot-prefix pattern..."
    # Example outcome after renaming:
    #   $target_root/.config
    #   $target_root/.docker
    #   $target_root/.zsh
    for entry in "$target_root"/*; do
        [[ -d "$entry" ]] || continue

        local name="${entry##*/}"
        if [[ "$name" == .* ]]; then
            continue
        fi

        local renamed="$target_root/.${name}"
        if [[ -e "$renamed" ]]; then
            warning "Skipping $name (target $renamed already exists)."
            continue
        fi

        if ! mv "$entry" "$renamed"; then
            warning "Unable to rename $entry to $renamed"
            continue
        fi
    done

    info "First-level folder structure:"
    ls -1 "$target_root"
}

if [[ "$SCRIPT_PATH" == "${0:A}" ]]; then
    install_configs
fi

