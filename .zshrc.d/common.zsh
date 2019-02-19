#
# Aliases
#
alias ll='ls -l'

autoload zmv
alias zmv="noglob zmv"
alias zcp="zmv -C"
alias zwild="zmv -p" # any command

alias perld="perl -MData::Dumper -E"
alias v=vagrant
alias vb='VBoxManage'
alias d='docker'
alias dm='docker-machine'
alias git=hub
alias ctags='/usr/local/bin/ctags'

function denv {
  # faster approach
  # https://github.com/docker/machine/issues/1884#issuecomment-169509429
  DOCKER_MACHINE_NAME=${1:-default}
  eval $(docker-machine inspect ${DOCKER_MACHINE_NAME} --format \
  "export DOCKER_HOST=tcp://{{ .Driver.IPAddress }}:2376
  export DOCKER_TLS_VERIFY=1
  export DOCKER_CERT_PATH={{ .HostOptions.AuthOptions.StorePath }}
  export DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME}")
}
alias renv='eval "$(rbenv init -)"'
alias nenv='eval "$(ndenv init -)"'
alias penv='eval $(perl -I$HOME/local/lib/perl5 -Mlocal::lib=$HOME/local)'
alias aenv='denv; renv; nenv; penv' # kick all *env

#
# ruby
#
RUBYGEMS_GEMDEPS=-

#
# git
#
path=(/usr/local/share/git-core/contrib/diff-highlight/ $path)

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
export CLICOLOR=true
export LSCOLORS='exfxcxdxbxGxDxabagacad'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'
#export EDITOR=vim
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=1000000
export LANG=ja_JP.UTF-8

##
## misc
##
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export GOPATH=$HOME/.go

##
## Docker Machine
##
# too heavy to load every time
# manually type denv
# if which docker-machine > /dev/null; then docker-machine active 2>/dev/null && eval "$(docker-machine env default)"; fi

dexec() { docker exec -it $1 bash -c "stty cols $COLUMNS rows $LINES && bash -l"; }
drun() { docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined "$@"; }
