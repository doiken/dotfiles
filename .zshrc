typeset -U path cdpath fpath manpath # 重複エントリを自動排除

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
path=($HOME/dotfiles/setup/ $HOME/bin/ $path)
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

# .zcompdump が24時間以内なら再スキャンを省略して高速化 (-C)
autoload -Uz compinit
() {
  setopt local_options extended_glob
  if [[ -n $HOME/.zcompdump(#qN.mh-24) ]]; then
    compinit -C
  else
    compinit
  fi
}

# tab x 2 で incremental search
# 	ref. https://qiita.com/aosho235/items/ee178ece3d514026b7ae
zstyle ':completion:*' menu select interactive

which aws_completer>/dev/null && complete -C 'aws_completer' aws

##
## Work Around: https://stackoverflow.com/questions/33452870/tmux-bracketed-paste-mode-issue-at-command-prompt-in-zsh-shell
##
[[ -n "$TMUX" ]] && unset zle_bracketed_paste

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# Created by `pipx` on 2022-07-29 08:53:15
export PATH="$PATH:/Users/doi_kenji/.local/bin"

# zoxide: 訪問履歴から cd 先を推測 (z <部分文字列> / zi で対話選択)
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
