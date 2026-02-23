#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Dotfiles bootstrap"
echo "    Source: $DOTFILES_DIR"
echo ""

# 1. Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Brewfile
echo "==> Installing Homebrew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 3. Stow packages
echo "==> Symlinking dotfiles with stow..."
cd "$DOTFILES_DIR"

packages=(zsh git starship mise bin)
for pkg in "${packages[@]}"; do
  echo "    Stowing $pkg..."
  stow --restow --target="$HOME" "$pkg"
done

echo ""
echo "==> Done! Restart your shell or run: source ~/.zshrc"
echo ""
echo "    Optional: run ./macos/defaults.sh to set macOS preferences"
