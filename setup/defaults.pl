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
# システム設定 > キーボード > キーボードショートカット > アプリケーションのショートカット
# に一覧表示させるための登録。ショートカット自体は NSUserKeyEquivalents で効くので、
# ここが失敗しても動作には影響しない。
# NOTE: macOS Ventura 以降 com.apple.universalaccess は TCC 保護されており、
#       ターミナルにフルディスクアクセスが無いと read/write ともに失敗する。
# フルディスクアクセス(FDA)の不足を通知で知らせる (長い出力に流れて気づけないため)。
# クリックで設定ペインが開く。FDA 不在は VSCode の動作低下の一因でもあるので、
# この機会に許可させたい。
my $FDA_PANE = 'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles';
my $fda_notified = 0;
sub notify_full_disk_access {
    return if $fda_notified++; # アプリごとに呼ばれるので通知は1回だけ
    return unless `which terminal-notifier 2>/dev/null`;
    system('terminal-notifier',
        '-title',    'dotfiles setup',
        '-subtitle', 'フルディスクアクセスが未許可です',
        '-message',  'ターミナルに許可してください (VSCode の動作低下の回避にもなります)',
        '-open',     $FDA_PANE);
}

sub add_custom_menu_entry {
    my ($app) = @_;
    die 'usage: addCustomMenuEntryIfNeeded com.company.appname' unless $app;

    my $current = `defaults read com.apple.universalaccess "com.apple.custommenu.apps" 2>/dev/null`;
    return if $current =~ /\Q${app}\E/;

    `defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array-add "${app}" 2>/dev/null`;
    my $after = `defaults read com.apple.universalaccess "com.apple.custommenu.apps" 2>/dev/null`;
    unless ($after =~ /\Q${app}\E/) {
        print "  WARN: ${app} を com.apple.custommenu.apps に登録できませんでした。\n";
        print "        ターミナルに「フルディスクアクセス」を許可すると登録できます。\n";
        print "        Chrome そのものには反映されており、システムショートカットに表示されないだけで動作自体には影響しません。\n";
        notify_full_disk_access();
    }
}

my %app_keys = (
		# 抽出方法
    #   1. 該当ドメインを調べる defaults domains | sed -e 's/,/\n/g' | grep -i APP_NAME
    #   2. 設定値を調べる       defaults read DOMAIN_NAME NSUserKeyEquivalents
    #   3. 値を貼り付ける
    # 修飾キー: @ = Cmd, ~ = Option, ^ = Control, $ = Shift
    'com.google.Chrome' => '{
        "\\U30bf\\U30d6\\U3092\\U56fa\\U5b9a" = "@~.";                          /* タブを固定           Cmd+Opt+.   */
        "\\U30bf\\U30d6\\U3092\\U8907\\U88fd" = "@k";                           /* タブを複製           Cmd+K       */
        "\\U524d\\U306e\\U30bf\\U30d6\\U3092\\U9078\\U629e" = "@~h";            /* 前のタブを選択       Cmd+Opt+H   */
        "\\U6b21\\U306e\\U30bf\\U30d6\\U3092\\U9078\\U629e" = "@~l";            /* 次のタブを選択       Cmd+Opt+L   */
        "\\U30c0\\U30a6\\U30f3\\U30ed\\U30fc\\U30c9" = "@~$l";                  /* ダウンロード         Cmd+Opt+Shift+L
                                                                                   ダウンロードの既定は Cmd+Opt+L で
                                                                                   「次のタブを選択」と衝突する。
                                                                                   明示的にずらして衝突を解消する。 */
        "Google Chrome \\U3092\\U96a0\\U3059" = "@~^$h";                        /* Google Chrome を隠す Cmd+Opt+Ctrl+Shift+H */
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
## ステータスバーを表示
`defaults write com.apple.Finder ShowStatusBar -bool "true"`;
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

# 充電時のチャイムを切る
`defaults write com.apple.PowerChime ChimeOnNoHardware -bool true;killall PowerChime`;
print "defaults com.apple.PowerChime\n" . `defaults read com.apple.PowerChime | grep -E 'ChimeOnNoHardware'` . "\n";

