#!/usr/bin/env bash
#
# macOS defaults
# Run manually: ./macos/defaults.sh
#

echo "Setting macOS defaults..."

# Ask for admin password upfront
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX
###############################################################################

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

###############################################################################
# Keyboard
###############################################################################

# Set a really fast keyboard repeat rate
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

###############################################################################
# Finder
###############################################################################

# Show the ~/Library folder
chflags nohidden ~/Library

# Show hidden files and file extensions
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable the warning when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show external drives and removable media on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Use list view in Finder by default
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

###############################################################################
# Safari
###############################################################################

# Hide bookmark bar
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Privacy: don't send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

###############################################################################
# Activity Monitor
###############################################################################

# Show main window on launch
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Show CPU usage in Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# Dock
###############################################################################

# Show indicator lights for open apps
defaults write com.apple.dock show-process-indicators -bool true

###############################################################################
# Networking
###############################################################################

# Use AirDrop over every interface
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

###############################################################################
# Done
###############################################################################

for app in "Activity Monitor" "Dock" "Finder" "Safari" "SystemUIServer"; do
  killall "${app}" &>/dev/null
done

echo "Done. Some changes require a restart to take effect."
