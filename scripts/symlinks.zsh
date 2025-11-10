#!/bin/zsh

SCRIPT_PATH="${(%):-%N}"
[[ "$SCRIPT_PATH" == "zsh" ]] && SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH:A}"
SCRIPT_DIR="${SCRIPT_PATH:h}"

CONFIG_FILE="$SCRIPT_DIR/symlinks/symlinks.conf"
STOW_PACKAGES_FILE="$SCRIPT_DIR/symlinks/stow-packages.conf"
DEFAULT_STOW_ROOT="$HOME/zeedots"

. "$SCRIPT_DIR/utils.zsh"

typeset -a STOW_PACKAGES=()
include_files=false

expand_path() {
    local raw="$1"
    if [[ -z "$raw" ]]; then
        printf ""
        return 0
    fi

    eval "printf '%s' \"$raw\""
}

resolve_stow_root() {
    local fallback="${ZEEDOTS_ROOT:-$DEFAULT_STOW_ROOT}"
    local raw_root="${1:-$fallback}"
    local candidate
    candidate="$(expand_path "$raw_root")"

    if [[ -z "$candidate" ]]; then
        error "Unable to resolve root directory. Specify it with --root <path>."
        return 1
    fi

    if [[ ! -d "$candidate" ]]; then
        error "Root directory '$candidate' not found. Run install_configs.zsh or adjust --root."
        return 1
    fi

    printf "%s" "$candidate"
}

ensure_stow_available() {
    if ! command -v stow >/dev/null 2>&1; then
        error "GNU Stow is not installed or not on PATH. Install it (e.g., 'brew install stow')."
        return 1
    fi
}

trim_line() {
    local line="$1"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    printf "%s" "$line"
}

load_stow_packages() {
    local stow_root="$1"
    STOW_PACKAGES=()

    if [[ -f "$STOW_PACKAGES_FILE" ]]; then
        while IFS= read -r raw || [[ -n "$raw" ]]; do
            raw="${raw%%#*}"
            local package
            package="$(trim_line "$raw")"
            [[ -z "$package" ]] && continue
            if [[ -d "$stow_root/$package" ]]; then
                STOW_PACKAGES+=("$package")
            else
                warning "Configured Stow package '$package' not found in $stow_root; skipping."
            fi
        done <"$STOW_PACKAGES_FILE"
    else
        for entry in "$stow_root"/*; do
            [[ -d "$entry" ]] || continue
            local name="${entry##*/}"
            STOW_PACKAGES+=("$name")
        done
    fi
}

apply_stow_packages() {
    local stow_root="$1"

    ensure_stow_available || return 1
    load_stow_packages "$stow_root"

    if (( ${#STOW_PACKAGES[@]} == 0 )); then
        info "No GNU Stow packages to apply."
        return 0
    fi

    info "Applying GNU Stow packages from $stow_root"

    for package in "${STOW_PACKAGES[@]}"; do
        if command stow --dir "$stow_root" --target "$HOME" --restow "$package"; then
            success "Stowed package: $package"
        else
            error "Failed to stow package: $package"
        fi
    done
}

unstow_packages() {
    local stow_root="$1"

    ensure_stow_available || return 1
    load_stow_packages "$stow_root"

    if (( ${#STOW_PACKAGES[@]} == 0 )); then
        info "No GNU Stow packages to remove."
        return 0
    fi

    info "Removing GNU Stow packages from $stow_root"

    for package in "${STOW_PACKAGES[@]}"; do
        if command stow --dir "$stow_root" --target "$HOME" -D "$package"; then
            success "Unstowed package: $package"
        else
            warning "Failed to unstow package: $package"
        fi
    done
}

usage() {
    cat <<EOF
Usage: $0 [--create | --delete] [--root <path>] [--include-files] [--help]

Options:
  --create             Create symlinks defined in the config file and apply GNU Stow packages.
  --delete             Remove symlinks defined in the config file and unstow packages.
  --root <path>        Root directory containing Zeedots packages (default: $DEFAULT_STOW_ROOT).
  --include-files      When deleting, also remove regular files referenced in symlinks.conf.
  --help               Show this help message.

Environment:
  ZEEDOTS_ROOT        Default root directory when --root is not provided.
EOF
}

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

create_symlinks() {
    local stow_root="$1"
    info "Creating symbolic links..."
    info "Using Zeedots root: $stow_root"

    while IFS=: read -r source target || [ -n "$source" ]; do
        if [[ -z "$source" || -z "$target" || "$source" == \#* ]]; then
            continue
        fi

        source=$(eval echo "$source")
        target=$(eval echo "$target")

        if [ ! -e "$source" ]; then
            error "Error: Source file '$source' not found. Skipping link creation for '$target'."
            continue
        fi

        if [ -L "$target" ]; then
            warning "Symbolic link already exists: $target"
        elif [ -e "$target" ]; then
            warning "File already exists: $target"
        else
            target_dir=$(dirname "$target")
            if [ ! -d "$target_dir" ]; then
                mkdir -p "$target_dir"
                info "Created directory: $target_dir"
            fi

            ln -s "$source" "$target"
            success "Created symbolic link: $target"
        fi
    done <"$CONFIG_FILE"

    apply_stow_packages "$stow_root" || warning "GNU Stow packages were not fully applied."
}

delete_symlinks() {
    local stow_root="$1"
    info "Deleting symbolic links..."
    info "Using Zeedots root: $stow_root"

    while IFS=: read -r _ target || [ -n "$target" ]; do
        if [[ -z "$target" ]]; then
            continue
        fi

        target=$(eval echo "$target")

        if [ -L "$target" ] || { [ "$include_files" == true ] && [ -f "$target" ]; }; then
            rm -rf "$target"
            success "Deleted: $target"
        else
            warning "Not found: $target"
        fi
    done <"$CONFIG_FILE"

    unstow_packages "$stow_root" || warning "GNU Stow packages were not fully removed."
}

if [[ "$SCRIPT_PATH" == "${0:A}" ]]; then
    action=""
    stow_root=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        "--create" | "--delete")
            if [[ -n "$action" ]]; then
                error "Multiple actions specified. Choose one of --create or --delete."
                exit 1
            fi
            action="$1"
            ;;
        "--root")
            shift
            if [[ -z "$1" ]]; then
                error "Missing value for --root."
                exit 1
            fi
            stow_root="$1"
            ;;
        "--root="*)
            stow_root="${1#*=}"
            ;;
        "--include-files")
            include_files=true
            ;;
        "--help")
            usage
            exit 0
            ;;
        *)
            error "Error: Unknown argument '$1'"
            usage
            exit 1
            ;;
        esac
        shift
    done

    if [[ -z "$action" ]]; then
        usage
        exit 1
    fi

    resolved_root="$(resolve_stow_root "$stow_root")" || exit 1

    case "$action" in
    "--create")
        create_symlinks "$resolved_root"
        ;;
    "--delete")
        delete_symlinks "$resolved_root"
        ;;
    esac
fi

