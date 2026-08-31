#!/bin/bash

##
## First of all, we need git
##
which brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
which git >/dev/null || brew install git

##
## Get This Repository
##
[ ! -d $HOME/dotfiles ] && git clone https://github.com/doiken/dotfiles.git $HOME/dotfiles

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
  .git_template
  .claude
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
BREW_LOG=/tmp/dotfiles_brew_bundle.log
echo "Running brew bundle in background... (see $BREW_LOG)"
{
	brew bundle --global >$BREW_LOG 2>&1
} &
##
## docker completion
## https://docs.docker.com/docker-for-mac/
##
# [ ! -e /usr/local/share/zsh/site-functions/_docker ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker.zsh-completion /usr/local/share/zsh/site-functions/_docker
# [ ! -e /usr/local/share/zsh/site-functions/_docker-machine ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker-machine.zsh-completion /usr/local/share/zsh/site-functions/_docker-machine
# [ ! -e /usr/local/share/zsh/site-functions/_docker-compose ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker-compose.zsh-completion /usr/local/share/zsh/site-functions/_docker-compose

wait
echo "brew bundle finished (see $BREW_LOG)"

##
## Touch ID for sudo (macOS 14.4+)
## https://qiita.com/y-vectorfield/items/3fc96150e63448a80c1b
##
if [ -f /etc/pam.d/sudo_local.template ] && ! grep -q '^auth.*pam_tid.so' /etc/pam.d/sudo_local 2>/dev/null; then
    echo "Enabling Touch ID for sudo (password required once)"
    {
        ## tmux/screen 内でも Touch ID を効かせる
        PAM_REATTACH=$(brew --prefix)/lib/pam/pam_reattach.so
        [ -f $PAM_REATTACH ] && echo "auth       optional       $PAM_REATTACH"
        sed 's/^#auth/auth/' /etc/pam.d/sudo_local.template
    } | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

##
## Configure
##
SCRIPTS=( $HOME/dotfiles/bin/defaults.pl )
for script in ${SCRIPTS[@]}; do
    [ -x $script ] && $script
done
