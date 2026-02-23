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
