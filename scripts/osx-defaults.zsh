#!/bin/zsh

SCRIPT_PATH="${(%):-%N}"
[[ "$SCRIPT_PATH" == "zsh" ]] && SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH:A}"
SCRIPT_DIR="${SCRIPT_PATH:h}"

. "$SCRIPT_DIR/utils.zsh"

apply_osx_system_defaults() {
    info "Applying OSX system defaults..."

    # Enable key repeats
    defaults write -g ApplePressAndHoldEnabled -bool true

    # Enable three finger drag
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

    # Disable prompting to use new exteral drives as Time Machine volume
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    # Hide external hard drives on desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

    # Hide hard drives on desktop
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

    # Hide removable media hard drives on desktop
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Hide mounted servers on desktop
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

    # Hide icons on desktop
    defaults write com.apple.finder CreateDesktop -bool true

    # Avoid creating .DS_Store files on network volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Show hidden files inside the finder
    defaults write com.apple.finder "AppleShowAllFiles" -bool true

    # Show Status Bar
    defaults write com.apple.finder "ShowStatusBar" -bool true

    # Do not show warning when changing the file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool true

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Set weekly software update checks
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 7

    # Spaces span all displays
    defaults write com.apple.spaces "spans-displays" -bool false

    # Do not rearrange spaces automatically
    defaults write com.apple.dock "mru-spaces" -bool false

    # Rectangle
    defaults write com.knollsoft.Rectangle curtainChangeSize -int 2
    defaults write com.knollsoft.Rectangle almostMaximizeHeight -float 1
    defaults write com.knollsoft.Rectangle almostMaximizeWidth -float 0.85

    # Rectangle custom window size with Shift + Alt + Ctrl + Cmd + N
    defaults write com.knollsoft.Rectangle specified -dict-add keyCode -float 45 modifierFlags -float 1966379
    defaults write com.knollsoft.Rectangle specifiedHeight -float 1055
    defaults write com.knollsoft.Rectangle specifiedWidth -float 1875
}

if [[ "$SCRIPT_PATH" == "${0:A}" ]]; then
    apply_osx_system_defaults
fi
