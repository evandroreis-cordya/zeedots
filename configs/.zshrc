# zsh Options
setopt HIST_IGNORE_ALL_DUPS

# Custom zsh
[ -f "$HOME/.config/zsh/custom.zsh" ] && source "$HOME/.config/zsh/custom.zsh"

# Aliases
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# Work
[ -f "$HOME/.config/zsh/work.zsh" ] && source "$HOME/.config/zsh/work.zsh"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/evandroreis/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions


# Homebrew Installations

# curl
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/curl/lib"
export CPPFLAGS="-I/opt/homebrew/opt/curl/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/curl/lib/pkgconfig"

# unzip
export PATH="/opt/homebrew/opt/unzip/bin:$PATH"

# postgresql@15
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# uv
export UV_LINK_MODE=copy


. "$HOME/.local/share/../bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/evandroreis/.lmstudio/bin"
# End of LM Studio CLI section

