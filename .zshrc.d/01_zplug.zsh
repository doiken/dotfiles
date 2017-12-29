#
# zplug
#
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# manually install by zplug install
zplug 'zsh-users/zsh-autosuggestions'
zplug 'zsh-users/zsh-completions'
zplug 'zsh-users/zsh-syntax-highlighting', defer:3
zplug "themes/robbyrussell", from:oh-my-zsh, as:theme
zplug "b4b4r07/gist", from:gh-r, as:command, use:"*darwin*amd64*"

zplug load
