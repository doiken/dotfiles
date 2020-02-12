#!/usr/bin/env bash
#
# NAME
#   pmset.sh
# USAGE
#   pmset.sh [STANDBY_DELAY_HOUR]
# DESCRIPTION
#   set pmset params

# ok to keep default
# lidwake              0
# powernap             0
# hibernatemode        3
standby_delay_hour=${1:-1}

sudo pmset -a powernap 0 standbydelaylow $(($standby_delay_hour * 60 * 60)) standbydelayhigh $(($standby_delay_hour * 60 * 60)) 
