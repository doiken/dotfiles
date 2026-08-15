#!/bin/bash
#
# Claude Code 通知スクリプト
# ref. https://qiita.com/take8/items/28bae27208580f0a2e44
#
# 概要:
#   Claude Code のフック機能を利用し、macOS のデスクトップ通知を送信する。
#   terminal-notifier を使用して通知を表示し、クリック時に元のターミナルをアクティブにする。
#
# 依存:
#   - terminal-notifier (brew install terminal-notifier)
#   - jq (brew install jq)
#
# 入力 (stdin):
#   JSON 形式。以下のフィールドを参照する:
#     - cwd              : カレントディレクトリ (通知のサブタイトルに使用)
#     - notification_type : 通知種別 ("permission_prompt" | "idle_prompt" | "stop")
#
# 通知種別:
#   permission_prompt : ツール実行の許可待ち (サウンド: Ping)
#   idle_prompt       : ユーザー入力待ち     (サウンド: Purr)
#   stop              : タスク完了           (サウンド: Glass)
#   error             : エラーで停止         (サウンド: Ping) ※ StopFailure フック
#
# 設定例 (~/.claude/settings.json):
#   {
#     "hooks": {
#       "Notification": [
#         { "matcher": "", "hooks": [{ "type": "command", "command": "~/.claude/scripts/notify.sh" }] }
#       ]
#     }
#   }
# NOTE VSCode では PermissionRequest が発火しない
# https://github.com/anthropics/claude-code/issues/11156
#

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
project=$(basename "$cwd")
notification_type=$(echo "$input" | jq -r '.notification_type')

# クリック時にフォーカスする端末アプリの Bundle ID。
#
# NOTE tmux 利用時は ~/.tmux.conf の update-environment への登録が必要。この変数は起動時に
#   設定されて以後は子プロセスへコピーされるだけなので、デーモンである tmux サーバ配下では
#   起動元アプリの値のまま固定される（VS Code から起動したサーバに iTerm2 で繋いでも
#   VS Code が前面化する）。登録すれば new-session / attach のたびに session environment が
#   更新され、そこから作られるペインが正しい値を受け取る。tmux 外なら登録は不要。
#
# NOTE 効くのは登録後に作られたペインのみ。実行中プロセスの環境変数は書き換えられない。
BUNDLE_ID="${__CFBundleIdentifier}"

send_notification() {
  local message="$1"
  local sound="$2"
  local args=(-title "Claude Code" -subtitle "${project}" -message "${message}")

  [[ -n "${sound}" ]] && args+=(-sound "${sound}")
  [[ -n "${BUNDLE_ID}" ]] && args+=(-activate "${BUNDLE_ID}")

  terminal-notifier "${args[@]}"
}

case "${notification_type}" in
  "permission_prompt")
    send_notification "許可待ち" "Ping"
    ;;
  "idle_prompt")
    # send_notification "入力待ち" "Purr"
    ;;
  "stop")
    send_notification "タスク完了" "Glass"
    ;;
  "error")
    send_notification "エラーで停止" "Ping"
    ;;
  *)
    send_notification "通知" ""
    ;;
esac