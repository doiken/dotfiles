##
## read all
##
for file in ~/.zshrc.d/*.zsh; do
  source "$file"
done

##
## User configuration
##
cdpath=(~/Documents ~ $cdpath)
path=($HOME/bin/ $path)
export PATH="$HOME/local/bin:$PATH"

##
## rbenv
##
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export PATH="$HOME/.rbenv/bin:$PATH"

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

##
## Work Around: https://stackoverflow.com/questions/33452870/tmux-bracketed-paste-mode-issue-at-command-prompt-in-zsh-shell
##
(( $+TMUX )) && unset zle_bracketed_paste


