##
## Alias
##
export SSH_STEP_SERVER=gw4
function fsh () {
  ssh -t ${SSH_STEP_SERVER} "sudo -u nn ssh $1"
}
# alias fsh="ssh -t ${SSH_STEP_SERVER} sudo -u nn ssh "
export SSH="ssh -t ${SSH_STEP_SERVER} sudo -u nn ssh " # for tssh
function fcp () {
  from=$1
  to=$2
  rsync -av -e "ssh -oClearAllForwardings=yes ${SSH_STEP_SERVER} sudo -u nn -i ssh" $from $to
}
##
## Env
##
export FOUT_HOME=/fout/fout/
