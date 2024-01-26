#
# zplug
#
export ZPLUG_HOME=$(brew --prefix)/opt/zplug
source $ZPLUG_HOME/init.zsh

# manually install by zplug install
zplug 'zsh-users/zsh-autosuggestions', as:plugin
zplug "zsh-users/zsh-completions", as:plugin
zplug 'zsh-users/zsh-syntax-highlighting', defer:2, as:plugin
zplug "themes/robbyrussell", from:oh-my-zsh, as:theme
zplug "greymd/docker-zsh-completion"

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load # --verbose # for debug

