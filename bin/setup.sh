#!/bin/bash

##
## Get This Repository
##
[ ! -d $HOME/dotfiles ] && git clone git@github.com:doiken/dotfiles.git $HOME/dotfiles

##
## Sym Link
##
DOT_FILES=(
  .hammerspoon
  bin
  .zsh
  .zshrc
  .zshenv
  .zprofile
  .gitconfig
  .gitignore_global
  .vimrc .ideavimrc
  .tmux.conf
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

BREW_EXECS=(
  git
  hub
  tmux
  peco
  reattach-to-user-namespace
  cask
  argon/mas/mas
  terminal-notifier
  gnupg
  gnupg2
  zplug
  rbenv
  ruby-build
  rbenv-gemset sqlparse
)
for e in ${BREW_EXECS[@]}
do
    brew list $e >/dev/null || brew install $e
done
brew install mysql --client-only

CASK_EXECS=(
  google-play-music-desktop-player
  ngrok
  bitbar
)
for e in ${CASK_EXECS[@]}
do
    brew cask list $e >/dev/null || brew cask install $e
done

##
## Configure
##
SCRIPTS=( ~/bin/key_repeat.sh )
for script in ${SCRIPTS[@]}
do
    [ -x $script ] && $script
done

