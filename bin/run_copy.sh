#!/usr/bin/env bash
#
# run shell and copy result
cmd=$(cd $(dirname $1) && pwd)/$(basename $1)
shift
# set LANG to call via IntelliJ IDEA external tools
# man pbcopy
# > pbcopy  and pbpaste use locale environment variables to determine the encoding to be used for input and output
$cmd "$@" | LANG=ja_JP.UTF-8 pbcopy
