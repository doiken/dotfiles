#!/usr/bin/env perl
#
# NAME
#   space2table.pl -- space or tab separated column to table format
# USAGE
#   space2table.pl
# DESCRIPTION
#   words not accepted: |, \t
my %parse_1st_line_func = (
    textile => sub {
        my ($separator, $line) = @_;
        $line =~ s/$separator/ |_. /g;
        return "|_. $line |\n";
    },
    markdown => sub {
        my ($separator, $line) = @_;
        $line =~ s/$separator/ | /g;
        my $col_num = (() = $line =~ /\|/gi) + 1; # col_nume = pipe count + 1
        $line = "| $line |\n";
        $line .= sprintf "|%s\n", ':---:|' x $col_num;
        return $line;
    },
);

my $i = 0;
my $type = $ARGV[0];
my $separator, $line;
while (<STDIN>){
    chomp;
    if ($i++ == 0) {
        $line = $_;
        $separator = ($line =~ /\t/) ? "\t" : " {2,}";
        $line = $parse_1st_line_func{$type}($separator, $line);
    } else {
        ($line = $_) =~ s/$separator/ | /g;
        $line = "| $line |\n";
    }
    print $line;
}
