##
## Alias
##
function _f_step () {
  # 社内サーバなら SSH_STEP_SERVER を更新
  first_arg=$(printf "%s\n" "$@" | grep -E -m 1 -v '^-')
  if [[ "$first_arg" == fjord* || "$first_arg" == ukigumo* ]]; then
    echo xp
  else
		echo gw
  fi
}
function fsh () {
  step_server=$(_f_step "$@")
  ssh -t ${step_server} "sudo -u nn ssh $@"
}
function db_tunnel () {
  ssh -tL 3306:127.0.0.1:13306 gw4 sudo -u nn ssh -tL 13306:127.0.0.1:3306 dbbackup
}
function fcp () {
  from=$1
  to=$2
  step_server=$(_f_step "$@")
  rsync -av -e "ssh -oClearAllForwardings=yes ${step_server} sudo -u nn -i ssh" $from $to
}
function redash_proxy () {
  ssh -tL 8080:localhost:8080 gw "sudo -u nn ssh -NL 8080:docker2.jp.fout.internal:5000 redash.log"
}
##
## Env
##
export FOUT_HOME=/fout/fout/
export PATH="${HOMEBREW_PREFIX}/opt/mysql-client/bin:$PATH"
# Keychain アクセスで起動をブロックしないよう遅延実行(zsh-defer 不在時は同期)
_load_redmine_api_key() { export REDMINE_API_KEY=$(security find-generic-password -s redmine-api-key -w); }
_load_redash_api_key() { export REDASH_API_KEY=$(security find-generic-password -s redash-api-key -w); }
if (( $+functions[zsh-defer] )); then
  zsh-defer _load_redmine_api_key
  zsh-defer _load_redash_api_key
else
  _load_redmine_api_key
  _load_redash_api_key
fi

# export GOOGLE_CLOUD_PROJECT=fout-dsp
function bsh () {
  ssh-add ~/.ssh/id_rsa_bastion
  ssh -At gw "ssh bastion $@"
}
function bshl () {
  ssh-add ~/.ssh/id_rsa_bastion
  ssh -AL 8157:localhost:8157 gw "ssh -ND 8157 bastion"
}

# 常駐プロセス用の tmux セッション。なければ作成し、あればアタッチする
# 左: 空き / 右: claude-rc(1/4), redmine(1/4), proxy(1/2, 手動起動用の空きシェル)
function dock {
  local s=dock
  # .tmux.conf の destroy-unattached on を上書きし、detach 後も残す
  # (未アタッチのセッションは次のコマンドまでに破棄されるため、1回の tmux 呼び出しにまとめる)
  # -t $s は分割直後のアクティブペインを指す
  tmux has-session -t "=$s" 2>/dev/null || tmux new-session -d -s $s -n dock \; \
    set -t $s destroy-unattached off \; \
    set -w -t $s pane-border-status top \; \
    set -w -t $s pane-border-format ' #{@name} ' \; \
    split-window -h -t $s -c "$HOME/Documents/work" \; \
    set -p -t $s @name claude-rc \; \
    send-keys -t $s 'caffeinate -i claude remote-control' C-m \; \
    split-window -v -t $s -l 75% \; \
    set -p -t $s @name redmine \; \
    send-keys -t $s 'autossh -M 0 -N xp_proxy' C-m \; \
    split-window -v -t $s -l 67% \; \
    set -p -t $s @name proxy \; \
    select-pane -t "$s:.{left}"
  if [[ -n $TMUX ]]; then tmux switch-client -t $s; else tmux attach -t $s; fi
}
