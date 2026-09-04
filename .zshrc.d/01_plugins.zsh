#
# plugins (sheldon)
# 設定: ~/.config/sheldon/plugins.toml / 更新: sheldon lock --update
#
if (( $+commands[sheldon] )); then
  eval "$(sheldon source)"
fi

#
# prompt (oh-my-zsh robbyrussell 風)
#
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr ' %F{yellow}✗'
zstyle ':vcs_info:git:*' formats ' %F{blue}git:(%F{red}%b%F{blue})%u%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}git:(%F{red}%b|%a%F{blue})%f'
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
PROMPT='%(?:%F{green}➜ :%F{red}➜ )%F{cyan}%c%f${vcs_info_msg_0_} '
