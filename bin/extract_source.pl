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
    scala => 'scala',
    py => 'python',
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
    my $selected_lines = join "\n", @selection;
    $selected_lines .= "\n...\n}" unless @selection[scalar @selection - 1] =~ /^}/;
    return $selected_lines;
}

my %funcs = (
    scala => {
        extract_module => sub {
            my ($lines, $line_start) = @_;
            my $ret = "";
            for (my $i = $line_start - 1; $i >= 0; $i--) {
                next if $lines->[$i] !~ /^.*class /;
                last if $i == $line_start - 1; # 定義を含む選択であれば定義の引用は不要

                # 閉じカッコが見つかるまで繋げることで定義の複数行に対応
                for(;$i < $line_start; $i++) {
                    $ret .= $lines->[$i] . "\n";
                    last if $lines->[$i] =~ /.*[{]/;
                }
                $ret .= "  ...";
                last;
            }
            return $ret;
        },
        extract_function => sub {
            my ($lines, $line_start) = @_;
            my $ret = "";
            for (my $i = $line_start - 1; $i >= 0; $i--) {
                next if $lines->[$i] !~ /^ *[(public|protected|private)].*def /;
                last if $i == $line_start - 1; # 定義を含む選択であれば定義の引用は不要

                # 閉じカッコが見つかるまで繋げることで定義の複数行に対応
                for(; $i < $line_start; $i++) {
                    $ret .= $lines->[$i] . "\n";
                    last if $lines->[$i] =~ /.*[\)}]/;
                }
                $ret .= "    ...";
                last;
            }
            return $ret;
        },
    },
    perl => {
        extract_module => sub {
            my ($lines, $line_start) = @_;
            my $ret = "";
            for (my $i = $line_start - 1; $i >= 0; $i--) {
                next if $lines->[$i] !~ /^package/;
                $ret = $lines->[$i];
                $ret .= "\n...";
                last;
            }
            return $ret;
        },
        extract_function => sub {
            my ($lines, $line_start) = @_;
            my $ret = "";
            for (my $i = $line_start - 1; $i >= 0; $i--) {
                next if $lines->[$i] !~ /^ *sub/;
                last if $i == $line_start - 1; # 定義を含む選択であれば定義の引用は不要

                # 閉じカッコが見つかるまで繋げることで定義の複数行に対応
                for(;$i < $line_start; $i++) {
                    $ret .= $lines->[$i] . "\n";
                    last if $lines->[$i] =~ /.*[\)}]/;
                }
                $ret .= "    ...";
                last;
            }
            return $ret;
        },
    },
    python => {
        extract_module => sub {
            my ($lines, $line_start) = @_;
            return '';
        },
        extract_function => sub {
            my ($lines, $line_start) = @_;
            my $ret = "";
            for (my $i = $line_start - 1; $i >= 0; $i--) {
                next if $lines->[$i] !~ /^ *def/;
                last if $i == $line_start - 1; # 定義を含む選択であれば定義の引用は不要

                # 閉じカッコが見つかるまで繋げることで定義の複数行に対応
                for(;$i < $line_start; $i++) {
                    $ret .= $lines->[$i] . "\n";
                    last if $lines->[$i] =~ /.*[\)}]/;
                }
                $ret .= "    ...";
                last;
            }
            return $ret;
        },
    },
);

sub main {
    my ($lines, $line_start, $line_end, $fn) = @_;
    my $current_module = $fn->{extract_module}($lines, $line_start);
    my $current_func = $fn->{extract_function}($lines, $line_start);
    my $selection = extract_lines($lines, $line_start, $line_end);
    # print $funcs{$lang}->($path, $line_start, $line_end);
    my $ret = <<EOS;
${current_module}
${current_func}
${selection}
EOS
    return $ret;
}

if (my $lang = $map{$ext}) {
    my $lines = read_file($path);
    print main($lines, $line_start, $line_end, $funcs{$lang});
} else {
    warn "extract function for ${ext} is not implemented.";
}
