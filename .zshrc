##
## tmux
##
[[ -z "$TMUX" && ! -z "$PS1" ]] && tmux

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
fpath=(~/.zsh/completion $fpath)

##
## rbenv
##
# too slow
# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
if [[ -f $HOME/.rbenv/bin ]]; then
	export PATH="$HOME/.rbenv/bin:$PATH"
fi

##
## for ndenv
##
if [[ -f $HOME/.ndenv/bin ]]; then
		export PATH="$HOME/.ndenv/bin:$PATH"
fi


##
## for peco
##
function history-peco() {
  local tac

  if which tac > /dev/null; then
    tac="tac"
  else
    tac="tail -r"
  fi

  BUFFER=$(history -n 1 | eval $tac | peco --query "$LBUFFER")
  CURSOR=$#BUFFER

  zle reset-prompt
}

zle -N history-peco
bindkey '^r' history-peco

##
## Work Around: https://stackoverflow.com/questions/33452870/tmux-bracketed-paste-mode-issue-at-command-prompt-in-zsh-shell
##
[[ -n "$TMUX" ]] && unset zle_bracketed_paste
