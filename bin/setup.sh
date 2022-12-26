#!/bin/bash

##
## Get This Repository
##
[ ! -d $HOME/dotfiles ] && git clone git@github.com:doiken/dotfiles.git $HOME/dotfiles

##
## Sym Link
##
DOT_FILES=(
  .Brewfile
  .hammerspoon
  bin
  .zsh
  .zshrc
  .zshenv
  .zprofile
  .gitconfig
  .gitignore_global
  .vimrc
  .ideavimrc
  .tmux.conf
  .ctags
  .tmpl
  .editrc
  $(echo $(cd ~/dotfiles/; echo .zshrc.d/*))
)

mkdir -p ~/.zshrc.d
for file in ${DOT_FILES[@]}
do
    [ ! -e $HOME/$file ] && ln -s $HOME/dotfiles/$file $HOME/$file
done

##
## Install Basics
##

## Homebrew
[ ! -x /usr/local/bin/brew ] && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew bundle --global &

##
## Configure
##
SCRIPTS=( ~/bin/key_repeat.sh )
for script in ${SCRIPTS[@]}; do
    [ -x $script ] && $script
done

##
## docker completion
## https://docs.docker.com/docker-for-mac/
##
# [ ! -e /usr/local/share/zsh/site-functions/_docker ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker.zsh-completion /usr/local/share/zsh/site-functions/_docker
# [ ! -e /usr/local/share/zsh/site-functions/_docker-machine ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker-machine.zsh-completion /usr/local/share/zsh/site-functions/_docker-machine
# [ ! -e /usr/local/share/zsh/site-functions/_docker-compose ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker-compose.zsh-completion /usr/local/share/zsh/site-functions/_docker-compose

wait

##
## node-build
##
if [ ! -d "$(ndenv root)/plugins/node-build" ]; then
  mkdir -p "$(ndenv root)"/plugins
  git clone https://github.com/riywo/node-build.git $(ndenv root)/plugins/node-build
fi
