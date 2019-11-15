#!/usr/bin/env bash
#
# run shell and copy result
cmd=$(cd $(dirname $1) && pwd)/$(basename $1)
shift
$cmd "$@" | pbcopy
