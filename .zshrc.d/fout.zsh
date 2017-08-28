##
## Alias
##
alias fsh="ssh -t gw4 sudo -u nn ssh "
export SSH="ssh -t gw4 sudo -u nn ssh " # for tssh
function fcp () {
  from=$1
  to=$2
  rsync -av -e 'ssh -oClearAllForwardings=yes gw4 sudo -u nn -i ssh' $from $to
}
##
## Env
##
export FOUT_HOME=/fout/fout/
