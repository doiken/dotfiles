#!/bin/bash

##
## Get This Repository
##
cd
git clone git@github.com:doiken/dotfiles.git

##
## Link
##
DOT_FILES=( bin .zsh .zshrc .zshenv .gitconfig .gitignore .vimrc .tmux.conf )

for file in ${DOT_FILES[@]}
do
    ln -s $HOME/dotfiles/$file $HOME/$file
done

##
## Install Basics
##

## install oh-my-zsh
[ ! -d ~/.oh-my-zsh ] && git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

## Homebrew
[ ! -x /usr/local/bin/brew ] && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

BREW_EXECS=( git tmux peco )
for e in ${BREW_EXECS[@]}
do
    brew install $e
done

