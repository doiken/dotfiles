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
setopt auto_list
setopt auto_menu
setopt auto_pushd
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_ignore_dups
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
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'
# eza: メタデータ列(権限・サイズ・日付・所有者)をグレーに抑えてファイル名の色を際立たせる
export EZA_COLORS="ur=38;5;245:uw=38;5;245:ux=38;5;245:ue=38;5;245:gr=38;5;245:gw=38;5;245:gx=38;5;245:tr=38;5;245:tw=38;5;245:tx=38;5;245:xa=38;5;245:sn=38;5;245:sb=38;5;245:da=38;5;245:uu=38;5;245:un=38;5;245:gu=38;5;245:gn=38;5;245"
export EDITOR=vim
# emacs キーバインドを明示。EDITOR=vim ではキーマップ viins が採用され Ctrl-E が ^E となるため
bindkey -e
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
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --inline-info --preview-window right:60%:wrap --preview='echo {}' --no-sort --exact" # man fzf
# fd をファイル・ディレクトリ列挙に使用
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
# 公式キーバインド: Ctrl-R 履歴 / Ctrl-T ファイル挿入 / Alt-C ディレクトリ移動
(( $+commands[fzf] )) && source <(fzf --zsh)


dexec() { docker exec -it $1 bash -c "stty cols $COLUMNS rows $LINES && bash -l"; }
drun() { docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined "$@"; }
