#!/usr/bin/env perl
#
# NAME
#   space2table.pl -- space or tab separated columns to table format
# USAGE
#   pbpaste | space2table.pl [textile or markdown] | pbcopy
# DESCRIPTION
#   words not accepted: " |\t"
my %parse_1st_line_func = (
    textile => sub {
        my ($separator, $line) = @_;
        $line =~ s/$separator/ |_. /g;
        return "{background:#E6E6E6}. |_. $line |\n";
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
my $separator, $line, $column_num;
while (<STDIN>){
    ($line .= $_) =~ s/^\s*(.*?)\s*$/$1/;
    if ($i++ == 0) {
        # 区切り文字の判定は先頭行のtab区切りの有無
        $separator = ($line =~ /\t/) ? "\t" : " {2,}";
        $column_num = scalar split($separator, $line);
        $line = $parse_1st_line_func{$type}($separator, $line);
    } elsif (scalar split($separator, $line) < $column_num) {
        # redash にてカラムが改行されるため区切り文字に整形
        # tobe
        #   ad_is_charged  cnt
        #   0  1,639,177
        #   1  226,692
        # asis
        #   ad_is_charged  cnt
        #   0
        #   1,639,177
        #   1
        #   226,692
        $line .= $separator;
        next;
    } else {
        $line =~ s/$separator/ | /g;
        $line = "| $line |\n";
    }
    print $line;
    $line = '';
}
