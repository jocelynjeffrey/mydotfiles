# Dotfiles Modernization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild the dotfiles repo from scratch using GNU Stow, modernized for current machine (macOS ARM, zsh, mise, Claude Code, Starship).

**Architecture:** Stow-based packages where each top-level directory maps to `$HOME`. Old files removed, new modular zsh config, 1Password CLI for secrets, Starship prompt.

**Tech Stack:** GNU Stow, zsh, oh-my-zsh, Starship, mise, 1Password CLI, Homebrew

---

### Task 1: Clean out old files

**Files:**
- Delete: `sublime/`, `iterm/`, `iterm2/`, `javascript/`, `shell/`, `zsh/`, `bin/`, `osx/`, `install/`
- Delete: `setup.sh`, `setup-new-machine.sh`, `remote-setup.sh`
- Keep: `.git/`, `.editorconfig`, `.gitattributes`, `LICENSE`, `docs/`

**Step 1: Remove all old directories and files**

```bash
cd /Users/jjeffrey/Documents/repos/mydotfiles
rm -rf sublime iterm iterm2 javascript shell zsh bin osx install
rm -f setup.sh setup-new-machine.sh remote-setup.sh
```

**Step 2: Verify only skeleton remains**

```bash
ls /Users/jjeffrey/Documents/repos/mydotfiles
```

Expected: `.editorconfig`, `.git`, `.gitattributes`, `.gitignore`, `LICENSE`, `README.md`, `docs/`

**Step 3: Commit**

```bash
git add -A && git commit -m "chore: remove all old dotfiles before restructure"
```

---

### Task 2: Create zsh stow package

**Files:**
- Create: `zsh/.zshrc`
- Create: `zsh/.zsh/aliases.zsh`
- Create: `zsh/.zsh/exports.zsh`
- Create: `zsh/.zsh/functions.zsh`
- Create: `zsh/.zsh/secrets.zsh`

**Step 1: Create directory structure**

```bash
mkdir -p /Users/jjeffrey/Documents/repos/mydotfiles/zsh/.zsh
```

**Step 2: Write `.zshrc`**

Create `zsh/.zshrc`:

```zsh
# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(z git)
COMPLETION_WAITING_DOTS="true"
source $ZSH/oh-my-zsh.sh

# Modular config
for file in ~/.zsh/*.zsh; do
  [ -r "$file" ] && source "$file"
done
unset file

# Starship prompt
eval "$(starship init zsh)"
```

**Step 3: Write `exports.zsh`**

Create `zsh/.zsh/exports.zsh`:

```zsh
# Editor
export EDITOR="claude"

# Language
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# mise (version manager)
eval "$(mise activate zsh)"

# Pager
export MANPAGER="less -X"
export PAGER="less"
export LESS="--quit-if-one-screen --no-init --ignore-case --chop-long-lines --RAW-CONTROL-CHARS --quiet --dumb"
```

**Step 4: Write `aliases.zsh`**

Create `zsh/.zsh/aliases.zsh` — curated from old `shell_aliases`, removing vagrant, atom, cask, Pygments, lwp-request, and other stale references:

```zsh
# Enable aliases to be sudo'ed
alias sudo="sudo "

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# File operations
alias mv='mv -v'
alias cp='cp -v'
alias ungz="gunzip -k"

# Clipboard
alias trimcopy="tr -d '\n' | pbcopy"
alias pubkey="cat ~/.ssh/id_ed25519.pub | pbcopy && echo 'Public key copied to clipboard'"

# Typo fixes
alias brwe=brew
alias where=which

# ls
alias l="ls -lF"
alias la="ls -laF"
alias lsd='ls -l | grep "^d"'
export CLICOLOR_FORCE=1

# Git shortcuts
alias g="git"
alias gs="git status"
alias gss="git status -s"
alias gd="git diff"
alias gl="git log"
alias glp5="git log -5 --pretty --oneline"
alias glt="git log --all --graph --decorate --oneline --simplify-by-decoration"
alias gp="git push origin HEAD"
alias gpu="git pull origin HEAD --prune"
alias gb="git branch"
alias gc="git checkout"
alias gcl="git clone"
alias gm="git commit -m"
alias gam="git commit -am"
alias gst="git stash"
alias gdtp="git stash pop"
alias gap="git add -p"
alias gsl="git shortlog -sn"
alias gws='git diff --shortstat "@{0 day ago}"'
alias gr='[ ! -z $(git rev-parse --show-cdup) ] && cd $(git rev-parse --show-cdup || pwd)'

# Network
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias flushdns="dscacheutil -flushcache"

# Utilities
alias cleanup_dsstore="find . -name '*.DS_Store' -type f -ls -delete"
alias diskspace_report="df -P -kHl"
alias fs="stat -f '%z bytes'"
alias get="curl -O -L"

# Finder
alias showdotfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidedotfiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"

# Shell config
alias zshconfig="$EDITOR ~/.zshrc"
alias reload="source ~/.zshrc && echo 'Shell config reloaded'"

# Hosts
alias hosts='sudo $EDITOR /etc/hosts'
```

**Step 5: Write `functions.zsh`**

Create `zsh/.zsh/functions.zsh` — keeping useful functions, removing gifify, webmify, shellswitch, code (VS Code), Python 2 server:

```zsh
# Create directory and cd into it
md() {
  mkdir -p "$@" && cd "$@"
}

# Find shorthand
f() {
  find . -name "$1" 2>&1 | grep -v 'Permission denied'
}

# cd into frontmost Finder window
cdf() {
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Copy with progress
cp_p() {
  rsync -WavP --human-readable --progress "$1" "$2"
}

# Get gzipped size
gz() {
  echo "orig size    (bytes): $(cat "$1" | wc -c)"
  echo "gzipped size (bytes): $(gzip -c "$1" | wc -c)"
}

# Extract archives
extract() {
  if [ -f "$1" ]; then
    local filename=$(basename "$1")
    local foldername="${filename%%.*}"
    local fullpath=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
    local didfolderexist=false
    if [ -d "$foldername" ]; then
      didfolderexist=true
      read -p "$foldername already exists, overwrite? (y/n) " -n 1
      echo
      if [[ $REPLY =~ ^[Nn]$ ]]; then return; fi
    fi
    mkdir -p "$foldername" && cd "$foldername"
    case $1 in
      *.tar.bz2) tar xjf "$fullpath" ;;
      *.tar.gz)  tar xzf "$fullpath" ;;
      *.tar.xz)  tar Jxvf "$fullpath" ;;
      *.tar.Z)   tar xzf "$fullpath" ;;
      *.tar)     tar xf "$fullpath" ;;
      *.tgz)     tar xzf "$fullpath" ;;
      *.tbz2)    tar xjf "$fullpath" ;;
      *.txz)     tar Jxvf "$fullpath" ;;
      *.zip)     unzip "$fullpath" ;;
      *) echo "'$1' cannot be extracted via extract()" && cd .. && ! $didfolderexist && rm -r "$foldername" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Start HTTP server (Python 3)
server() {
  local port="${1:-8000}"
  open "http://localhost:${port}/"
  python3 -m http.server "$port"
}

# Git: list branches sorted by recent updates
git_list_branches() {
  for branch in $(git branch | sed s/^..//); do
    time_ago=$(git log -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $branch --)
    tracks_upstream=$(if [ "$(git rev-parse $branch@{upstream} 2>/dev/null)" ]; then printf "★"; fi)
    printf "%-53s - %s %s\n" "$time_ago" "$branch" "$tracks_upstream"
  done | sort
}
alias gbt=git_list_branches
```

**Step 6: Write `secrets.zsh`**

Create `zsh/.zsh/secrets.zsh`:

```zsh
# Secrets loaded from 1Password at shell startup
# Requires: op CLI authenticated (biometric via 1Password desktop app)
#
# To add a new secret:
#   1. Store it in 1Password
#   2. Add an op read line below
#   3. Use: op read "op://Vault/Item/field"

# Only load if op is available and authenticated
if command -v op &>/dev/null; then
  export SENTRY_USER_AUTH_TOKEN=$(op read "op://Private/Sentry User Auth Token/credential" 2>/dev/null)
  export ROLLBAR_KEY=$(op read "op://Private/Rollbar Key/credential" 2>/dev/null)
fi
```

**Step 7: Commit**

```bash
git add zsh/ && git commit -m "feat: add zsh stow package with modular config"
```

---

### Task 3: Create git stow package

**Files:**
- Create: `git/.gitconfig`
- Create: `git/.gitignore_global`

**Step 1: Write `.gitconfig`**

Create `git/.gitconfig`:

```ini
[user]
	name = Jocelyn Jeffrey
	email = jocelynjeffrey@gmail.com

[core]
	editor = claude
	abbrev = 12
	attributesfile = ~/.gitattributes
	excludesfile = ~/.gitignore_global
	autocrlf = input
	ignorecase = false

[color]
	ui = always

[color "branch"]
	current = green bold
	local = green
	remote = yellow

[color "diff"]
	frag = magenta
	meta = yellow
	new = green
	old = red

[color "diff-highlight"]
	oldNormal = red bold
	oldHighlight = "red bold 52"
	newNormal = "green bold"
	newHighlight = "green bold 22"

[grep]
	extendRegexp = true

[credential]
	helper = osxkeychain

[fetch]
	prune = true

[pull]
	rebase = true

[init]
	defaultBranch = main

[merge]
	conflictstyle = diff3
```

**Step 2: Write `.gitignore_global`**

Create `git/.gitignore_global`:

```
# macOS
.DS_Store
._*
.Spotlight-V100
.Trashes

# Editors
.idea/
.vscode/
*.swp
*.swo
*~

# Git
.gitconfig.local

# Dependencies
node_modules/
bower_components/

# Environment
.env
.env.local

# Python
*.pyc
__pycache__/

# Thumbnails
Thumbs.db
Desktop.ini
```

**Step 3: Commit**

```bash
git add git/ && git commit -m "feat: add git stow package"
```

---

### Task 4: Create starship stow package

**Files:**
- Create: `starship/.config/starship.toml`

**Step 1: Create directory structure**

```bash
mkdir -p /Users/jjeffrey/Documents/repos/mydotfiles/starship/.config
```

**Step 2: Write `starship.toml`**

Create `starship/.config/starship.toml` — minimal, no Nerd Font icons, Operator Mono friendly:

```toml
# Starship prompt config
# No Nerd Font icons — plain text symbols only

format = """
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$ruby\
$cmd_duration\
$line_break\
$character"""

[character]
success_symbol = "[>](bold green)"
error_symbol = "[>](bold red)"

[directory]
truncation_length = 3
truncation_symbol = ".../"

[git_branch]
symbol = ""
format = "on [$branch]($style) "

[git_status]
format = '([$all_status$ahead_behind]($style) )'
conflicted = "="
ahead = "^"
behind = "v"
diverged = "^v"
untracked = "?"
stashed = "$"
modified = "!"
staged = "+"
renamed = "r"
deleted = "x"

[nodejs]
symbol = ""
format = "node [$version]($style) "
detect_files = ["package.json", ".node-version"]

[python]
symbol = ""
format = "py [$version]($style) "

[ruby]
symbol = ""
format = "rb [$version]($style) "

[cmd_duration]
min_time = 2_000
format = "took [$duration]($style) "
```

**Step 3: Commit**

```bash
git add starship/ && git commit -m "feat: add starship stow package"
```

---

### Task 5: Create mise stow package

**Files:**
- Create: `mise/.config/mise/config.toml`

**Step 1: Create directory structure**

```bash
mkdir -p /Users/jjeffrey/Documents/repos/mydotfiles/mise/.config/mise
```

**Step 2: Write `config.toml`**

Create `mise/.config/mise/config.toml` — matches current machine config:

```toml
[settings]
idiomatic_version_file_enable_tools = ["node", "python", "ruby", "java"]

[tools]
node = "18.20.2"
```

**Step 3: Commit**

```bash
git add mise/ && git commit -m "feat: add mise stow package"
```

---

### Task 6: Create bin stow package

**Files:**
- Create: `bin/.local/bin/ssh-key`
- Create: `bin/.local/bin/crlf`
- Create: `bin/.local/bin/git-delete-merged-branches`

**Step 1: Create directory structure**

```bash
mkdir -p /Users/jjeffrey/Documents/repos/mydotfiles/bin/.local/bin
```

**Step 2: Write `ssh-key`**

Create `bin/.local/bin/ssh-key` — modernized to use ed25519:

```bash
#!/usr/bin/env bash
# Print public SSH key to clipboard. Generate if necessary.

file="$HOME/.ssh/id_ed25519.pub"
if [ ! -f "$file" ]; then
  ssh-keygen -t ed25519
fi
cat "$file"
```

**Step 3: Write `git-delete-merged-branches`**

Create `bin/.local/bin/git-delete-merged-branches` — updated to use `main` as default branch:

```bash
#!/usr/bin/env bash
# Delete local and remote branches that have been merged to main

default_branch="${1:-main}"

branches_to_die=$(git branch --no-color --merged "origin/$default_branch" | grep -v "\s$default_branch$")
echo "Local branches to be deleted:"
echo "$branches_to_die"

remote_branches_to_die=$(git branch --no-color --remote --merged "origin/$default_branch" \
  | grep -v "\s$default_branch$" \
  | grep -v "/$default_branch$" \
  | grep -v "origin/HEAD" \
  | grep -v "origin/$default_branch")
echo ""
echo "Remote branches to be deleted:"
echo "$remote_branches_to_die"

echo ""
echo "Enter Y to confirm"
read -p "> " confirm

if [[ "$confirm" == "Y" ]]; then
  echo "$branches_to_die" | xargs -n 1 git branch -d
  for remote in $remote_branches_to_die; do
    git branch -rd "$remote"
  done
fi

echo ""
echo "Pruning all remotes"
git remote | xargs -n 1 git remote prune
```

**Step 4: Make scripts executable and commit**

```bash
chmod +x bin/.local/bin/*
git add bin/ && git commit -m "feat: add bin stow package with utility scripts"
```

Note: `crlf` script is omitted — it uses `local` outside a function (bash error) and is niche. `batcharge.py` and `nyan` dropped per design.

---

### Task 7: Create macos defaults script

**Files:**
- Create: `macos/defaults.sh`

**Step 1: Create directory**

```bash
mkdir -p /Users/jjeffrey/Documents/repos/mydotfiles/macos
```

**Step 2: Write `defaults.sh`**

Create `macos/defaults.sh` — cleaned up from old `osx/set-defaults.sh`, removing Twitter app, fixing `kill all` typo (was `kill all` with a space, should be `killall`):

```bash
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
```

**Step 3: Make executable and commit**

```bash
chmod +x macos/defaults.sh
git add macos/ && git commit -m "feat: add macOS defaults script"
```

---

### Task 8: Create Brewfile, .gitignore, and README

**Files:**
- Create: `Brewfile`
- Modify: `.gitignore`
- Modify: `README.md`

**Step 1: Write `Brewfile`**

Create `Brewfile` — based on actually installed formulae, keeping the useful ones:

```ruby
# Taps
tap "homebrew/bundle"

# Core tools
brew "git"
brew "gh"
brew "mise"
brew "stow"
brew "starship"
brew "jq"
brew "yq"
brew "wget"
brew "curl"

# Development
brew "direnv"
brew "lefthook"
brew "src-cli"

# Languages & runtimes
brew "python@3.13"
brew "ruby-build"
brew "rbenv"

# Database
brew "postgresql@16"
brew "redis"

# Security
brew "gitleaks"
brew "gnupg"

# Mobile
brew "cocoapods"
brew "watchman"

# Casks
cask "1password-cli"
```

**Step 2: Update `.gitignore`**

Overwrite `.gitignore`:

```
.DS_Store
*.swp
*.swo
*~
```

**Step 3: Update `README.md`**

Overwrite `README.md`:

```markdown
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
```

**Step 4: Commit**

```bash
git add Brewfile .gitignore README.md && git commit -m "feat: add Brewfile, update gitignore and README"
```

---

### Task 9: Create install.sh bootstrap script

**Files:**
- Create: `install.sh`

**Step 1: Write `install.sh`**

Create `install.sh`:

```bash
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
```

**Step 2: Make executable and commit**

```bash
chmod +x install.sh
git add install.sh && git commit -m "feat: add bootstrap install script"
```

---

### Task 10: Update .editorconfig and clean up root

**Files:**
- Keep: `.editorconfig` (already fine)
- Delete: `.gitattributes` (root level — git package has its own)

**Step 1: Remove redundant root .gitattributes**

The git stow package doesn't need a `.gitattributes` in home (the repo's `.gitattributes` is for the repo itself, which is fine to keep). Actually, keep it — it's for the repo.

**Step 2: Final commit with any remaining cleanup**

```bash
git status
# If anything left over, add and commit
```

---

### Task 11: Test the stow packages (dry run)

**Step 1: Verify stow dry-run for each package**

This does NOT actually create symlinks — just shows what would happen:

```bash
cd /Users/jjeffrey/Documents/repos/mydotfiles
for pkg in zsh git starship mise bin; do
  echo "=== $pkg ==="
  stow --simulate --target="$HOME" "$pkg" 2>&1
  echo ""
done
```

Expected: No errors. May show conflicts if existing files (like `~/.zshrc`) already exist — that's expected and will be handled during actual install by backing up first.

**Step 2: Note any conflicts for the user**

If conflicts exist (e.g., `~/.zshrc` already exists), document them. The user will need to back up or remove existing files before stowing.

---

### Task 12: Install stow and starship, then apply

**Requires internet** — skip if wifi is down, come back later.

**Step 1: Install stow and starship**

```bash
brew install stow starship
```

**Step 2: Back up existing configs that will conflict**

```bash
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup
[ -f ~/.gitconfig ] && mv ~/.gitconfig ~/.gitconfig.backup
[ -d ~/.config/mise ] && mv ~/.config/mise ~/.config/mise.backup
```

**Step 3: Run stow**

```bash
cd /Users/jjeffrey/Documents/repos/mydotfiles
stow --target="$HOME" zsh git starship mise bin
```

**Step 4: Verify symlinks**

```bash
ls -la ~/.zshrc ~/.gitconfig ~/.config/starship.toml ~/.config/mise/config.toml ~/.local/bin/ssh-key
```

Expected: All pointing to files in `~/Documents/repos/mydotfiles/...`

**Step 5: Source and test**

```bash
source ~/.zshrc
```

Expected: Shell reloads with Starship prompt, no errors.

**Step 6: Commit any final adjustments**

```bash
cd /Users/jjeffrey/Documents/repos/mydotfiles
git add -A && git status
# Commit if needed
```
