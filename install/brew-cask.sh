#!/bin/bash

# Install Caskroom
brew tap caskroom/cask
brew install brew-cask
brew tap caskroom/versions

# Install packages
apps=(
    1password
    dropbox
    google-drive
    flux
    iterm2
    atom
    firefox
    google-chrome
    malwarebytes-anti-malware
    spotify
    slack
)

brew cask install "${apps[@]}"
