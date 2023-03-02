##
## read all
##
for file in ~/.zshrc.d/*.zsh; do
  source "$file"
done

##
## User configuration
##
cdpath=(~/Documents ~/Repositories ~ $cdpath)
path=($HOME/bin/ $path)
fpath=(
  ~/.zsh/completion
  $fpath
  ${HOMEBREW_PREFIX}/share/zsh/site-functions
)

##
## compinit
##

# for aws cli completion
# see: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html
autoload bashcompinit && bashcompinit

autoload -Uz compinit && compinit

which aws_completer>/dev/null && complete -C 'aws_completer' aws

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
## Work Around: https://stackoverflow.com/questions/33452870/tmux-bracketed-paste-mode-issue-at-command-prompt-in-zsh-shell
##
[[ -n "$TMUX" ]] && unset zle_bracketed_paste

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# Created by `pipx` on 2022-07-29 08:53:15
export PATH="$PATH:/Users/doi_kenji/.local/bin"
