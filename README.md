# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup

```bash
# 1. Clone
git clone https://github.com/jocelynjeffrey/mydotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Run bootstrap
./install.sh
```

## Manual setup

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages
brew bundle

# Symlink dotfiles
stow zsh git starship mise bin

# (Optional) Set macOS defaults
./macos/defaults.sh
```

## Structure

Each top-level directory is a Stow package that symlinks into `$HOME`:

| Package | Contents |
|---------|----------|
| `zsh/` | `.zshrc` and modular `.zsh/*.zsh` configs |
| `git/` | `.gitconfig` and `.gitignore_global` |
| `starship/` | Starship prompt config |
| `mise/` | mise version manager config |
| `bin/` | Utility scripts in `~/.local/bin/` |
| `macos/` | macOS defaults (run manually, not stowed) |

## Secrets

Secrets are loaded from 1Password CLI at shell startup. See `zsh/.zsh/secrets.zsh`.

## Adding a new config

1. Create a directory for the package: `mkdir -p newpkg/.config/tool/`
2. Add config files mirroring the `$HOME` path structure
3. Run `stow newpkg`
