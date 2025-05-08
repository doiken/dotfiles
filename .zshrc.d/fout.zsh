##
## Alias
##
function _f_step () {
  # 社内サーバなら SSH_STEP_SERVER を更新
  first_arg=$(printf "%s\n" "$@" | grep -E -m 1 -v '^-')
  if [[ "$first_arg" == fjord* || "$first_arg" == ukigumo* ]]; then
    echo xp0_global
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
##
## Env
##
export FOUT_HOME=/fout/fout/
export PATH="${HOMEBREW_PREFIX}/opt/mysql-client@8.0/bin:$PATH"
funciton bsh () {
  ssh-add ~/.ssh/id_rsa_bastion
  ssh -At gw "ssh bastion $@"
}
funciton bshl () {
  ssh-add ~/.ssh/id_rsa_bastion
  ssh -AL 8157:localhost:8157 gw "ssh -ND 8157 bastion"
}
