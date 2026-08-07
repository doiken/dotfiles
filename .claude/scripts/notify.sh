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
#   error             : エラーで停止         (サウンド: Basso) ※ StopFailure フック
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

# ターミナルアプリの Bundle ID を自動検出
get_terminal_bundle_id() {
  # __CFBundleIdentifier が設定されていれば直接使用（最も確実）
  if [[ -n "${__CFBundleIdentifier}" ]]; then
    echo "${__CFBundleIdentifier}"
    return
  fi

  # TERM_PROGRAM 環境変数から検出（フォールバック）
  case "${TERM_PROGRAM}" in
    "Apple_Terminal") echo "com.apple.Terminal" ;;
    "iTerm.app")      echo "com.googlecode.iterm2" ;;
    "ghostty")        echo "com.mitchellh.ghostty" ;;
    "WarpTerminal")   echo "dev.warp.Warp-Stable" ;;
    *)
      # プロセスツリーから検出
      local pid parent comm
      pid=$$
      while [[ "${pid}" -ne 1 ]] 2>/dev/null; do
        parent=$(ps -p "${pid}" -o ppid= 2>/dev/null | tr -d ' ') || break
        [[ -z "${parent}" ]] && break
        comm=$(ps -p "${parent}" -o comm= 2>/dev/null)
        case "${comm}" in
          *Terminal*)  echo "com.apple.Terminal"; return ;;
          *iTerm*)     echo "com.googlecode.iterm2"; return ;;
          *Cursor*)    echo "com.todesktop.230313mzl4w4u92"; return ;;
          *Code*)      echo "com.microsoft.VSCode"; return ;;
          *warp*)      echo "dev.warp.Warp-Stable"; return ;;
          *)           ;;
        esac
        pid="${parent}"
      done
      echo ""
      ;;
  esac
}

BUNDLE_ID=$(get_terminal_bundle_id)

send_notification() {
  local message="$1"
  local sound="$2"

  if [[ -n "${BUNDLE_ID}" ]]; then
    terminal-notifier -title "Claude Code" -subtitle "${project}" -message "${message}" -sound "${sound}" -activate "${BUNDLE_ID}"
  else
    terminal-notifier -title "Claude Code" -subtitle "${project}" -message "${message}" -sound "${sound}"
  fi
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