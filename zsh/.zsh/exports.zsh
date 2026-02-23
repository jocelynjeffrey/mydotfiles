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

# Pager
export MANPAGER="less -X"
export PAGER="less"
export LESS="--quit-if-one-screen --no-init --ignore-case --chop-long-lines --RAW-CONTROL-CHARS --quiet --dumb"
