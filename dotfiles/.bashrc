# PATH
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$(go env GOPATH)/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.local/share/pnpm:$PATH"
export CC="$(which gcc)"
export CXX="$(which g++)"
# env
export EDITOR=nvim
export TERM="xterm-256color"
export BUN_INSTALL="$HOME/.bun"
export CODEX_HOME="${CODEX_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/codex}"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
# base
git_branch() {
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        echo " ($branch)"
    fi
}
PS1='-> \[\e[36m\]\w\[\e[0m\]$(git_branch) $ '
# base
shopt -s autocd
bind '"\C-n" menu-complete'
bind '"\C-p" menu-complete-backward'
# bind '"\C-k" previous-history'
# bind '"\C-j" next-history'
mkcd(){ mkdir -p -- "$1" && cd -- "$1"; }
# alias
alias ...="../.."
alias ls="ls --color=auto"
alias grep='grep --color=auto'
alias xbps-install="sudo xbps-install"
alias xbps-remove="sudo xbps-remove"
alias oc="opencode"
alias sp="sudo ss -ltnup | grep LISTEN"
alias sd="sudo sv restart docker"
export PATH="$HOME/.gem/ruby/3.4.0/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export CAPACITOR_ANDROID_STUDIO_PATH="$HOME/.local/bin/studio.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
[[ -r "$HOME/.grok/completions/bash/grok.bash" ]] && source "$HOME/.grok/completions/bash/grok.bash"
# <<< grok installer <<<
