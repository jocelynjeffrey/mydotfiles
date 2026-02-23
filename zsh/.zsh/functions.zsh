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
