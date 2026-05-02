# Editor
export EDITOR="claude"

# Language
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Local scripts
export PATH="$HOME/.local/bin:$PATH"
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# mise (version manager)
eval "$(mise activate zsh)"

# Sourcegraph (Wealthsimple private instance)
export SRC_ENDPOINT="https://wealthsimple.sourcegraphcloud.com"

# Pager
export MANPAGER="less -X"
export PAGER="less"
export LESS="--quit-if-one-screen --no-init --ignore-case --chop-long-lines --RAW-CONTROL-CHARS --quiet --dumb"

# 1Password SSH agent
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
