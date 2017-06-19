#
# Aliases
#
alias ll='ls -l'

#
# Work Around: https://stackoverflow.com/questions/33452870/tmux-bracketed-paste-mode-issue-at-command-prompt-in-zsh-shell
#
(( $+TMUX )) && unset zle_bracketed_paste

#
# git
#
path=(/usr/local/share/git-core/contrib/diff-highlight/ $path)
precmd () { vcs_info }
PS1='%1~ ${vcs_info_msg_0_}%f%# '
zstyle ':vcs_info:*' actionformats '[%b]% '
zstyle ':vcs_info:*' formats       '[%b]% '

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
#setopt share_history
setopt transient_rprompt

#
# Exports
#
export CLICOLOR=true
export LSCOLORS='exfxcxdxbxGxDxabagacad'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'
#export EDITOR=vim
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=1000000
export LANG=ja_JP.UTF-8


