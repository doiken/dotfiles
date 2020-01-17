#!/usr/bin/env bash
perl -lne 'BEGIN { my $i = 0 } { my $prefix = $i++ == 0 ? "_." : ""; s/  +/ |$prefix /g; print "|$prefix $_ |" }'
