#!/usr/bin/env bash
#
# NAME
#   pmset.sh
# USAGE
#   pmset.sh HIBERNATEMODE STANDBY_DELAY_HOUR
# DESCRIPTION
#   set pmset params
#   ref: man pmset
#   ref: https://apple.stackexchange.com/questions/113954/difference-between-autopoweroff-and-standby-in-pmset
# ok to keep default
# lidwake              0
# powernap             0
hibernatemode=$1
standby_delay_hour=$2

sudo pmset -a \
  hibernatemode $hibernatemode \
  sleep 60 \
  displaysleep 60 \
  disksleep 60 \
  powernap 0 \
  standbydelaylow $((1 + $standby_delay_hour * 60 * 60)) \
  standbydelayhigh $((1 + $standby_delay_hour * 60 * 60)) \
  autopoweroffdelay $((1 + $standby_delay_hour * 60 * 60)) \
  destroyfvkeyonstandby 0
