# zplug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

for file in ~/.zshrc.d/*.zsh; do
  source "$file"
done

##
## User configuration
##
cdpath=(~/Documents ~)
path=($HOME/bin/ $path)
export PATH="$HOME/local/bin:$PATH"

##
## rbenv
##
export PATH="$HOME/.nodebrew/current/bin:$HOME/bin/:$HOME/.rbenv/shims:$HOME/.nodebrew/current/bin:$HOME/bin/:$HOME/.rbenv/shims:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.nodebrew/current/bin:$HOME/bin/:$HOME/.rbenv/shims:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

##
## for NodeBrew
##
if [[ -f $HOME/.nodebrew/nodebrew ]]; then
    export PATH=$HOME/.nodebrew/current/bin:$PATH
fi

##
## for Docker
##
if which docker-machine > /dev/null; then eval "$(docker-machine env default >/dev/null 2>&1)"; fi

##
## for Peco
##
function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history


