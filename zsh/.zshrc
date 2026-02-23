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
