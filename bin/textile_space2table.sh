#!/usr/bin/env bash
perl -lne 'BEGIN { my $i = 0 } { my $prefix = $i++ == 0 ? "_." : ""; s/\t/ |$prefix /g; print "|$prefix $_ |" }'
