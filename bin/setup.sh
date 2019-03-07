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
  .vimrc
  .ideavimrc
  .tmux.conf
  .ctags
  .tmpl
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
  reattach-to-user-namespace
  cask
  terminal-notifier
  zplug
  peco
  jq
  the_silver_searcher
  python3
  ndenv
  pipenv
  ctags
  # heavy app had better to be last
  rbenv
  ruby-build
  mysql
)
{
  PATTERN="$(brew list | xargs echo | perl -pe 's/ /|/g')"
  for e in ${BREW_EXECS[@]}
  do
      [ "$(egrep -v \"$PATTERN\" <(echo $e))" != "" ] && brew install $e
  done
} &
CASK_EXECS=(
  google-chrome
  google-japanese-ime
  iterm2
  hammerspoon
  clipy
  marshallofsound-google-play-music-player
  ngrok
  bitbar
  visual-studio-code
  keycastr # print what you type
  licecap  # capture as gif
  skitch
  slack
  pycharm-ce
  intellij-idea-ce
  mapture
  # heavy app had better to be last
  vagrant
  java
  virtualbox
  docker
)
{
  PATTERN="$(brew cask list | xargs echo | perl -pe 's/ /|/g')"
  for e in ${CASK_EXECS[@]}
  do
      [ "$(egrep -v $PATTERN <(echo $e))" != "" ] && brew cask install $e
  done
} &

##
## Configure
##
SCRIPTS=( ~/bin/key_repeat.sh )
for script in ${SCRIPTS[@]}
do
    [ -x $script ] && $script
done

##
## docker completion
## https://docs.docker.com/docker-for-mac/
##
[ ! -e /usr/local/share/zsh/site-functions/_docker ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker.zsh-completion /usr/local/share/zsh/site-functions/_docker
[ ! -e /usr/local/share/zsh/site-functions/_docker-machine ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker-machine.zsh-completion /usr/local/share/zsh/site-functions/_docker-machine
[ ! -e /usr/local/share/zsh/site-functions/_docker-compose ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker-compose.zsh-completion /usr/local/share/zsh/site-functions/_docker-compose

wait
