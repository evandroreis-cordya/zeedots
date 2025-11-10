#!/bin/zsh

SCRIPT_PATH="${(%):-%N}"
[[ "$SCRIPT_PATH" == "zsh" ]] && SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH:A}"
SCRIPT_DIR="${SCRIPT_PATH:h}"

. "$SCRIPT_DIR/utils.zsh"

install_vscode_extensions() {
    info "Installing VSCode extensions..."

    # List of Extensions
    extensions=(
        42crunch.vscode-openapi
        aaron-bond.better-comments
        actboy168.lua-debug
        adpyke.codesnap
        alefragnani.bookmarks
        amazonwebservices.amazon-nova-act-extension
        amazonwebservices.aws-toolkit-vscode
        anthropic.claude-code
        asvetliakov.vscode-neovim
        bierner.markdown-mermaid
        codezombiech.gitignore
        coenraads.bracket-pair-colorizer-2
        davidanson.vscode-markdownlint
        eamodio.gitlens
        esbenp.prettier-vscode
        firsttris.vscode-jest-runner
        github.vscode-github-actions
        julianiaquinandi.nvim-ui-modifier
        lumirelle.shell-format-rev
        luxcium.pop-n-lock-theme-vscode
        mechatroner.rainbow-csv
        ms-azuretools.vscode-containers
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-python.black-formatter
        ms-python.debugpy
        ms-python.flake8
        ms-python.isort
        ms-python.python
        ms-python.vscode-pylance
        ms-python.vscode-python-envs
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.vscode-jupyter-slideshow
        ms-vscode.powershell
        mtxr.sqltools
        pkief.material-icon-theme
        redhat.vscode-yaml
        sumneko.lua
        tamasfe.even-better-toml
        timonwong.shellcheck
        vscode-icons-team.vscode-icons
        vscodevim.vim
        yandeu.five-server
        zainchen.json
        zhuangtongfa.material-theme
    )

    for e in "${extensions[@]}"; do
        code --install-extension "$e"
    done

    success "VSCode extensions installed successfully"
}

if [[ "$SCRIPT_PATH" == "${0:A}" ]]; then
    install_vscode_extensions
fi
