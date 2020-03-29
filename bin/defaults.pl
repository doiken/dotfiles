#!/usr/bin/env perl
#
# NAME
#   defaults.pl
# USAGE
#   defaults.pl
# DESCRIPTION
#   modify mac settings by defaults
use strict;
use warnings;
use constant {
    CMD_KEY   => '@',
    CTRL_KEY  => '^',
    OPT_KEY   => '~',
    SHIFT_KEY => '$',
};
sub add_custom_menu_entry {
    my ($app) = @_;
    die 'usage: addCustomMenuEntryIfNeeded com.company.appname' unless $app;

    my $grep =`defaults read com.apple.universalaccess "com.apple.custommenu.apps" | grep ${app}`;
    `defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array-add "${app}"` if $grep;
}

my %app_keys = (
    'com.google.Chrome' => "{
        '\\U30bf\\U30d6\\U3092\\U56fa\\U5b9a' = '${\CMD_KEY}${\OPT_KEY},';
        '\\U30bf\\U30d6\\U3092\\U8907\\U88fd' = '${\CMD_KEY}k';
        '\\U524d\\U306e\\U30bf\\U30d6\\U3092\\U9078\\U629e' = '${\CMD_KEY}${\OPT_KEY}h';
        '\\U6b21\\U306e\\U30bf\\U30d6\\U3092\\U9078\\U629e' = '${\CMD_KEY}${\OPT_KEY}l';
    }",
);

for my $app (keys %app_keys) {
    `defaults write ${app} NSUserKeyEquivalents "${\ $app_keys{$app} }"`;
    add_custom_menu_entry($app);
}

# screen swiching
`defaults write com.apple.universalaccess "reduceMotion" 1`;

# key repeat
`defaults write -g InitialKeyRepeat -int 14`; # normal minimum is 15 (225 ms)
`defaults write -g KeyRepeat -int 1`; # normal minimum is 2 (30 ms)

# restart modified apps by your self to make keys enabled
`killall cfprefsd`;