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
prompt_path() {
    local git_root rel
    # 1) git リポジトリ内なら git root からの相対パスを表示
    git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ -n "$git_root" && ( "$PWD" == "$git_root" || "$PWD" == "$git_root"/* ) ]]; then
        if [[ "$PWD" == "$git_root" ]]; then
            basename "$git_root"
        else
            printf '%s/%s' "$(basename "$git_root")" "${PWD#"$git_root"/}"
        fi
        return
    fi
    # 2) ghq 配下 (git 管理なし) なら basename のみ
    local ghq_root line full best="" best_len=0
    ghq_root="$(ghq root 2>/dev/null)"
    if [[ -n "$ghq_root" && "$PWD" == "$ghq_root"/* ]]; then
        while IFS= read -r line; do
            full="$ghq_root/$line"
            if [[ "$PWD" == "$full" || "$PWD" == "$full"/* ]] && (( ${#line} > best_len )); then
                best="$line"
                best_len=${#line}
            fi
        done < <(ghq list)
        if [[ -n "$best" ]]; then
            basename "$best"
            return
        fi
    fi
    # 3) それ以外は ~ 置換のフルパス
    printf '%s' "${PWD/#$HOME/\~}"
}
PS1='-> \[\e[36m\]$(prompt_path)\[\e[0m\]$(git_branch) $ '
# base
shopt -s autocd
bind '"\C-n" menu-complete'
bind '"\C-p" menu-complete-backward'
# bind '"\C-k" previous-history'
# bind '"\C-j" next-history'
mkcd(){ mkdir -p -- "$1" && cd -- "$1"; }
projects-fzf() {
  local root selected path name config_dirs=()
  root="$(ghq root)"

  for dir in "$HOME/.config"/*/; do
    [[ -d "${dir}.git" ]] && config_dirs+=("${dir#$HOME/}")
  done

  selected=$(
    {
      ghq list
      printf '%s\n' "${config_dirs[@]}"
    } | fzf --height 40% --reverse
  )

  [[ -z "$selected" ]] && return

  if [[ -d "$root/$selected" ]]; then
    path="$root/$selected"
  elif [[ -d "$HOME/$selected" ]]; then
    path="$HOME/$selected"
  else
    return
  fi

  name="$(basename "$path")"

  # すでにそのセッションにいるなら cd だけ（switch だと無反応に見える）
  if [[ -n "${TMUX:-}" ]]; then
    current="$(tmux display-message -p '#S' 2>/dev/null)"
    if [[ "$current" == "$name" ]]; then
      cd "$path" || return
      return
    fi
  fi

  if tmux has-session -t "=$name" 2>/dev/null; then
    if [[ -n "${TMUX:-}" ]]; then
      tmux switch-client -t "=$name"
    else
      tmux attach-session -t "=$name"
    fi
  else
    if [[ -n "${TMUX:-}" ]]; then
      tmux new-session -ds "$name" -c "$path"
      tmux switch-client -t "=$name"
    else
      tmux new-session -s "$name" -c "$path"
    fi
  fi
}
bind -x '"\C-g": projects-fzf'
# fzf shell integration (Ctrl+R 履歴検索 / Ctrl+T ファイル名 / Alt+C ディレクトリ移動)
eval "$(fzf --bash)"
# alias
alias ...="../.."
alias ls="ls --color=auto"
alias grep='grep --color=auto'
alias xbps-install="sudo xbps-install"
alias xbps-remove="sudo xbps-remove"
alias oc="opencode"
alias sp="sudo ss -ltnup | grep LISTEN"
alias sd="sudo sv restart docker"
# nixos-rebuild shortcut: ホスト名から自動で flake config を選ぶ
nrs() {
  local flake_dir="/home/mame/ghq/github.com/mame77/nix-config"
  (cd "$flake_dir" && sudo nixos-rebuild "$@" --flake ".#$(hostname -s)")
}
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
