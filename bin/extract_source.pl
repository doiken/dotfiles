#!/usr/bin/env perl
# 
# NAME
#   extract_source.pl -- 選択した行(複数行含む)とそのモジュール, 関数名を返す
# USAGE
#   extract_source.pl FILE_PATH LINE_START LINE_END
# DESCRIPTION
#   今はperlだけ対応
use strict;
use warnings;

my ($path, $line_start, $line_end) = @ARGV;
my ($ext) = $path =~ /\.([^.]+)$/;

# 拡張子と展開処理のマッピング
my %map = (
    pl => 'perl',
    pm => 'perl',
);

sub read_file {
    my ($path) = @_;

    open my $handle, '<', $path;
    chomp(my @lines = <$handle>);
    close $handle;
    return \@lines;
}
# extract given lines
sub extract_lines {
    my ($lines, $line_start, $line_end) = @_;
    my @selection = ();
    for (my $i = ($line_start - 1); $i < $line_end; $i++) {
        # 配列は0開始、行は1開始のため調整
        push(@selection, $lines->[$i]);
    }
    return \@selection;
}

my %funcs = (
    perl => sub {
        my ($path, $line_start, $line_end) = @_;
        my $lines = read_file($path);
        my $selection = extract_lines($lines, $line_start, $line_end);

        # TODO: moduleの複数定義
        my $head = $lines->[0];
        my $last_sub = "";
        for (my $i = $line_end - 1; $i > 0; $i--) {
            if ($lines->[$i] =~ /^ *sub/) {
                # TODO: 関数定義が複数行
                $last_sub = $lines->[$i];
                last;
            }
        }
        my $selected_lines = join "\n", @$selection;
        my $ret = <<EOS;
${head}
...
${last_sub}
    ...
${selected_lines}
}
EOS
        return $ret;
    },
);

if (my $lang = $map{$ext}) {
    print $funcs{$lang}->($path, $line_start, $line_end);
} else {
    warn "extract function for ${ext} is not implemented.";
}
