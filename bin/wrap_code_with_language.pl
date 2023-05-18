#!/usr/bin/env perl
# 
# NAME
#   wrap_code_with_language.pl -- 与えられたコードを code ブロックにして返す
# USAGE
#   wrap_code_with_language.pl CODE_BLOCK
my @lines = <STDIN>;

sub guess_language {
    my $code = shift;
    if ($code =~ /^\s*(sub|my) /m) {
        return 'perl';
    } elsif ($code =~ /^\s*(select|insert|update|delete table|drop table|alter table|create table) /mi) {
        return 'sql';
    } elsif ($code =~ /[^\$]\$ /m) {
        return 'bash';
    } elsif ($code =~ /^(val|case) /m || $code =~ / new /m ) {
        return 'scala';
    } elsif ($code =~ /^(def|if [a-zA-Z]) /m || $code =~ / for [^ ]+ in /m ) {
        return 'python';
    } else {
        return 'python';
    }
}

(my $code = join("", @lines)) =~ s/\s*$//;
my $language = guess_language($code);
my $pre = <<"EOC";
<pre><code class="${language}">
${code}
</code></pre>
EOC

print $pre

