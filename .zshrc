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
# fpath と compinit は .zshrc.d/01_plugins.zsh + sheldon 側(fzf-tab より前に実行が必要)

##
## completion styles
##

# for aws cli completion
# see: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html
autoload bashcompinit && bashcompinit
which aws_completer>/dev/null && complete -C 'aws_completer' aws

# あいまいマッチ: 完全一致 → 大文字小文字無視 → 区切り文字(._-)またぎの部分一致
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
# 候補をグループ化して見出し表示(fzf-tab では [説明] 形式・< > でグループ切替)
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# 重い補完(brew, docker 等)をキャッシュ
zstyle ':completion:*' use-cache true
# 候補選択は fzf-tab に任せる
zstyle ':completion:*' menu no

# fzf-tab
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:(vi|vim|bat|cat|code):*' fzf-preview 'bat --color=always --style=numbers --line-range=:80 $realpath 2>/dev/null || eza -1 --color=always $realpath'

##
## Work Around: https://stackoverflow.com/questions/33452870/tmux-bracketed-paste-mode-issue-at-command-prompt-in-zsh-shell
##
[[ -n "$TMUX" ]] && unset zle_bracketed_paste

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# uv tool / pipx などがインストールするユーザーローカルの実行ファイル
path=($path $HOME/.local/bin)

# zoxide: 訪問履歴から cd 先を推測 (z <部分文字列> / zi で対話選択)
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
