#
# Profile
#
# 会社支給機 (fout) か個人機 (home) かのフラグ。dotfiles/Brewfile の出し分けにも使う
if [[ -z "$DOTFILES_PROFILE" ]]; then
  case "$USER" in
    doi_kenji) export DOTFILES_PROFILE=fout ;;
    *)         export DOTFILES_PROFILE=home ;;
  esac
fi

export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/Brewfile" # --file なしで dotfiles を見せる
export HOMEBREW_DOTFILES_PROFILE="$DOTFILES_PROFILE"  # brew は HOMEBREW_ 以外を渡さない

#
# Aliases
#
if (( $+commands[eza] )); then
  alias ll='eza -l --git'
  alias la='eza -la --git'
  alias tree='eza --tree'
else
  alias ll='ls -lh'
  alias la='ls -lhaF'
fi
(( $+commands[bat] )) && alias cat='bat --paging=never'

autoload zmv
alias zmv="noglob zmv"
alias zcp="zmv -C"
alias zwild="zmv -p" # any command

alias perld="perl -MData::Dumper -E"
alias d='docker'
alias dc='docker compose'

function cl { claude "$@"; }
function cr { claude --resume "$@"; }
function cf { claude --resume --fork-session "$@"; }

function tc  { tmux new-session claude "$@"; }
function tcr { tmux new-session claude --resume "$@"; }
function tcf { tmux new-session claude --resume --fork-session "$@"; }

function csr  { claude_session resume "$@"; }
function tcsr { tmux new-session claude_session resume "$@"; }

# 素の diff も delta で表示(元の diff は command diff)
if (( $+commands[delta] )); then
  function diff { command diff -u "$@" | delta; }
fi

# mise: python/node/perl/ruby のバージョン管理(旧 pyenv/nodenv/plenv/rbenv + xenv)
(( $+commands[mise] )) && eval "$(mise activate zsh)"

function mode_op {
  # トグルしたい prompt
  p='[%* doiken@%1~]\$ '
  if [ "$PROMPT_BACK" != "" ]; then
    export PROMPT=$PROMPT_BACK
    export PROMPT_BACK=""
  else
    export PROMPT_BACK=$PROMPT
    export PROMPT="$p"
  fi
}
# see: https://zenn.dev/kumamoto/articles/d536ac6df8a544
alias man='env LANG=C man'
alias jman='env LANG=ja_JP.UTF-8 man'

# General settings
#
setopt auto_cd
setopt auto_list
setopt auto_menu
setopt auto_pushd
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
# setopt ignore_eof
setopt inc_append_history
setopt interactive_comments
setopt no_beep
setopt no_hist_beep
setopt no_list_beep
setopt magic_equal_subst
setopt notify
setopt print_eight_bit
#setopt print_exit_value
setopt prompt_subst
setopt pushd_ignore_dups
setopt rm_star_wait
setopt share_history
setopt transient_rprompt

#
# Exports
#
export LESS="-iRMXS"
export CLICOLOR=true
export LSCOLORS='exfxcxdxbxGxDxabagacad'
# zsh 補完(.zshrc の list-colors)専用。export すると eza に継承され theme.yml の色を上書きするため付けない
LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'
# eza: 配色は ~/.config/eza/theme.yml で管理する
# man は XDG_CONFIG_HOME 未設定時に $HOME/.config/eza へフォールバックすると書くが、0.23.5 は実際にはしないため明示する
export EZA_CONFIG_DIR="$HOME/.config/eza"
export EDITOR=vim
# emacs キーバインドを明示。EDITOR=vim ではキーマップ viins が採用され Ctrl-E が ^E となるため
bindkey -e
# bat/delta のシンタックステーマ(VS Code の GitHub Dark に寄せる)
export BAT_THEME="Visual Studio Dark+"
# man を bat で色付き表示
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000
export LANG=ja_JP.UTF-8

##
## misc
##
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export GOPATH=$HOME/.go

##
## for fzf
##
export FZF_DEFAULT_OPTS="--height 80% --layout=reverse --border --info=inline" # man fzf
# 履歴(Ctrl-R): コマンド全文を下3行に表示。exact/no-sort は履歴検索だけに適用
export FZF_CTRL_R_OPTS="--no-sort --exact --preview 'echo {}' --preview-window down:3:wrap"
# ファイル(Ctrl-T)・ディレクトリ(Alt-C): 中身をプレビュー
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:100 {} 2>/dev/null || eza -1 --color=always {}'"
export FZF_ALT_C_OPTS="--preview 'eza -1 --color=always {}'"
# fd をファイル・ディレクトリ列挙に使用
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
# 公式キーバインド: Ctrl-R 履歴 / Ctrl-T ファイル挿入 / Alt-C ディレクトリ移動
(( $+commands[fzf] )) && source <(fzf --zsh)


dexec() { docker exec -it $1 bash -c "stty cols $COLUMNS rows $LINES && bash -l"; }
drun() { docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined "$@"; }
