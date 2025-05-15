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
sub add_custom_menu_entry {
    my ($app) = @_;
    die 'usage: addCustomMenuEntryIfNeeded com.company.appname' unless $app;

    my $grep =`defaults read com.apple.universalaccess "com.apple.custommenu.apps" | grep ${app}`;
    `defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array-add "${app}"` unless $grep;
}

my %app_keys = (
		# 抽出方法
    #   1. 該当ドメインを調べる defaults domains | sed -e 's/,/\n/g' | grep -i APP_NAME
    #   2. 設定値を調べる       defaults read DOMAIN_NAME NSUserKeyEquivalents
    #   3. 値を貼り付ける
    'com.google.Chrome' => '{
        "\\U30bf\\U30d6\\U3092\\U56fa\\U5b9a" = "@$,";
        "\\U30bf\\U30d6\\U3092\\U8907\\U88fd" = "@k";
        "\\U524d\\U306e\\U30bf\\U30d6\\U3092\\U9078\\U629e" = "@~h";
        "\\U6b21\\U306e\\U30bf\\U30d6\\U3092\\U9078\\U629e" = "@~l";
        "Google Chrome \\U3092\\U96a0\\U3059" = "@~^$h";
    }',
    'com.jetbrains.intellij.ce' => '{
        "Hide IntelliJ IDEA" = "@~^h";
    }',
);

for my $app (keys %app_keys) {
    print "add shortcut for ${app}...\n";
    `defaults write ${app} NSUserKeyEquivalents '${\ $app_keys{$app} }'`;
    add_custom_menu_entry($app);
    print "result:\n";
    print `defaults read ${app} NSUserKeyEquivalents `, "\n";
}

my ($before, $after);

# Dock
## Dockからすべてのアプリを消す
# `defaults write com.apple.dock persistent-apps -array`;
`defaults write com.apple.dock "mru-spaces" -bool "false"`;
`defaults write com.apple.dock "show-recents" -bool "false"`;
print "defaults read com.apple.dock\n" . `defaults read com.apple.dock | grep -E 'mru-spaces|show-recents'` . "\n";

# key repeat
`defaults write -g InitialKeyRepeat -int 14`; # normal minimum is 15 (225 ms)
`defaults write -g KeyRepeat -int 1`; # normal minimum is 2 (30 ms)

# Finder
## 拡張子まで表示
`defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"`;
## 隠しファイルを表示
`defaults write com.apple.Finder "AppleShowAllFiles" -bool "true"`;
## パスバーを表示
`defaults write com.apple.Finder ShowPathbar -bool "true"`;
## ゴミ箱を空にするときの警告無効化
`defaults write com.apple.Finder WarnOnEmptyTrash -bool "false"`;
print "defaults com.apple.Finder\n" . `defaults read com.apple.Finder | grep -E 'AppleShowAllFiles|ShowPathbar|WarnOnEmptyTrash'` . "\n";

# Battery
## バッテリーを%表示
`defaults write com.apple.menuextra.battery ShowPercent -string "YES"`;
print "defaults defaults com.apple.menuextra.battery\n" . `defaults read com.apple.menuextra.battery | grep -E 'ShowPercent'` . "\n";

# Trackpad
## タップでクリック
`defaults write com.apple.AppleMultitouchTrackpad Clicking -bool "true"`;
print "defaults com.apple.AppleMultitouchTrackpad\n" . `defaults read com.apple.AppleMultitouchTrackpad | grep -E 'Clicking'` . "\n";

# restart modified apps by your self to make keys enabled
`killall cfprefsd`;
