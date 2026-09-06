#
# completion 用 fpath(sheldon 内で compinit が走るため、ここで先に完成させる)
#
fpath=(
  ~/.zsh/completion
  $fpath
  ${HOMEBREW_PREFIX}/share/zsh/site-functions
)

# 薄字サジェストを履歴+補完エンジンの両方から出す
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

#
# plugins (sheldon)
# 設定: ~/.config/sheldon/plugins.toml / 更新: sheldon lock --update
#
if (( $+commands[sheldon] )); then
  eval "$(sheldon source)"
fi

#
# prompt (robbyrussell 風の git 表示 + 記号は zsh 標準の %#)
# %# … 一般ユーザーは %、root は # に展開され権限が一目で分かる
#
autoload -Uz vcs_info
# check-for-changes は付けない(コマンドごとの git diff を避ける)
# 配色は青〜cyan の類似色で統一し、明度で cwd > branch > 装飾 の階層を作る。
# 唯一の異色は失敗時の赤。16 色のみを使うため端末のテーマに追従する。
# 12=bright blue(cwd) 6=cyan(branch) 8=bright black(装飾) 4=blue(成功) 1=red(失敗)
zstyle ':vcs_info:git:*' formats ' %F{8}git:(%F{6}%b%F{8})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{8}git:(%F{6}%b|%a%F{8})%f'
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
PROMPT='%F{12}%c%f${vcs_info_msg_0_} %(?:%F{4}:%F{1})%#%f '
