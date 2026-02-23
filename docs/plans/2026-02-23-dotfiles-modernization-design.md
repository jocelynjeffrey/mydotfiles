# Dotfiles Modernization Design

**Date**: 2026-02-23
**Status**: Approved

## Context

Dotfiles repo has drifted from actual machine setup. Rebuilding from current state using modern tooling.

## Decisions

- **Dotfile management**: GNU Stow (modular packages, one command to symlink)
- **Secrets**: 1Password CLI (`op read`) — secrets never touch the repo
- **Editor**: Claude Code (`claude`) as default EDITOR
- **Prompt**: Starship (plain text mode, no Nerd Font icons)
- **Font**: Operator Mono (already installed, no patching)
- **Terminal theme**: Keep existing iTerm setup, don't manage themes in dotfiles

## Repo Structure

```
mydotfiles/
├── zsh/                    # Stow package → ~
│   ├── .zshrc
│   └── .zsh/
│       ├── aliases.zsh
│       ├── functions.zsh
│       ├── exports.zsh
│       └── secrets.zsh     # op read calls
├── git/                    # Stow package → ~
│   ├── .gitconfig
│   └── .gitignore_global
├── starship/               # Stow package → ~
│   └── .config/
│       └── starship/
│           └── starship.toml
├── mise/                   # Stow package → ~
│   └── .config/
│       └── mise/
│           └── config.toml
├── bin/                    # Stow package → ~
│   └── .local/
│       └── bin/
│           └── (scripts)
├── macos/                  # NOT stowed — run manually
│   └── defaults.sh
├── Brewfile
├── install.sh
├── README.md
└── .gitignore
```

## Zsh Config

`.zshrc` is a slim orchestrator:
- Sources oh-my-zsh with plugins (z, git)
- Sources all `~/.zsh/*.zsh` files
- Initializes Starship prompt

Modular files in `.zsh/`:
- `aliases.zsh` — curated from old shell_aliases, removing stale (vagrant, atom)
- `exports.zsh` — PATH (homebrew, mise), EDITOR=claude, LANG/LC
- `functions.zsh` — useful ones (extract, md, f, server), removing dead ones (gifify, shellswitch)
- `secrets.zsh` — 1Password CLI references for SENTRY_USER_AUTH_TOKEN, etc.

## Git Config

- User: Jocelyn Jeffrey (personal email)
- Editor: claude
- Credential helper: osxkeychain
- Fetch prune, color settings retained
- Atom/Sublime references removed

## Starship

Minimal `starship.toml`:
- Git branch/status with plain text symbols
- Node/Python version in relevant directories
- No Nerd Font icons

## Brewfile

Generated from current machine via `brew bundle dump`.

## Bootstrap (install.sh)

1. Install Homebrew if missing
2. `brew bundle` (installs stow, starship, and everything else)
3. `stow zsh git starship mise bin`
4. Prompt to run `macos/defaults.sh`

## Removed

| Item | Reason |
|------|--------|
| `sublime/` | Not using Sublime |
| `iterm/` + `iterm2/` | Managed by iTerm directly |
| `javascript/.eslintrc.js` | Project-specific |
| `batcharge.py` | Python 2, unused |
| `setup-new-machine.sh` | Replaced by install.sh |
| `remote-setup.sh` | Unused |
| `shell/bash*` | Using zsh, not bash |
| `zsh/themes/` | Replaced by Starship |
| `bin/nyan` | Novelty |
