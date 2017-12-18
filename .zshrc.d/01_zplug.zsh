#
# zplug
#
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# run command after installed
zplug "peco/peco", as:command, from:gh-r

zplug 'zsh-users/zsh-autosuggestions'
zplug 'zsh-users/zsh-completions'
zplug 'zsh-users/zsh-syntax-highlighting', defer:3
zplug "themes/robbyrussell", from:oh-my-zsh, as:theme

if ! zplug check --verbose; then
  printf 'Install? [y/N]: '
  if read -q; then
    echo; zplug install
  fi
fi

#
# Autoloadings
#

autoload -Uz add-zsh-hook
autoload -Uz compinit && compinit -u
autoload -Uz url-quote-magic
autoload -Uz vcs_info

zplug load
