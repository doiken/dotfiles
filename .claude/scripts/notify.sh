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
#     - cwd               : カレントディレクトリ (通知のサブタイトルに使用)
#     - notification_type : 通知種別 ("permission_prompt" | "idle_prompt" | "stop" | "error")
#     - transcript_path   : セッションの transcript (stop 時のサブエージェント実行中判定に使用)
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
#       ],
#       "Stop": [
#         { "matcher": "", "hooks": [{ "type": "command", "command": "jq -c '. + {\"notification_type\": \"stop\"}' | ~/.claude/scripts/notify.sh" }] }
#       ]
#     }
#   }
#   Stop / StopFailure はフックの stdin JSON (transcript_path 含む) をそのまま渡すこと。
#
# NOTE 通知を出しっぱなし (クリックするまで消えない) にするには、システム設定 > 通知 >
#   terminal-notifier の通知スタイルを「警告」に変更する。terminal-notifier 単体では
#   通知ごとにスタイルを変えられない。
#
# NOTE VSCode では PermissionRequest が発火しない
# https://github.com/anthropics/claude-code/issues/11156
#

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
[[ -z "${cwd}" ]] && cwd=$PWD
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

# サブエージェント実行中の Stop かどうかを判定する。
#
# サブエージェントに投げただけのターン終了は「タスク完了」ではない
# (ユーザーのアクションが不要なため通知しない)。
#
# 判定方法: transcript 上で、最後のユーザーメッセージ以降に
#   - 起動されたサブエージェント: tool_result に "Async agent launched" を含む tool_use_id
#   - 完了通知: queue-operation の <task-notification> 内の <tool-use-id>
#   の差分が残っていれば実行中とみなす。
#
# 「最後のユーザーメッセージ以降」に限定するのは、中断等で完了通知が来ないまま
# 残ったエージェントが以後の stop 通知を永久に抑制するのを防ぐため。
# 判定に失敗した場合は通知する側に倒れる。
has_running_subagents() {
  local transcript="$1"
  [[ -f "${transcript}" ]] || return 1

  local pending
  pending=$(jq -n '
    reduce inputs as $e (
      {launched: [], notified: []};
      if $e.type == "user"
         and ($e.isMeta != true)
         and (($e.message.content | type) == "string"
              or ([$e.message.content[]? | select(.type == "tool_result")] | length) == 0)
      then {launched: [], notified: []}
      else
        .launched += [$e.message.content[]?
                      | select(.type == "tool_result")
                      | select((.content | tostring) | contains("Async agent launched"))
                      | .tool_use_id]
        | .notified += [$e
                        | select(.type == "queue-operation")
                        | .content // ""
                        | scan("<tool-use-id>([^<]+)</tool-use-id>")
                        | .[0]]
      end
    )
    | .launched - .notified | length
  ' "${transcript}" 2>/dev/null)

  [[ "${pending}" =~ ^[0-9]+$ ]] && (( pending > 0 ))
}

case "${notification_type}" in
  "permission_prompt")
    send_notification "許可待ち" "Ping"
    ;;
  "idle_prompt")
    # send_notification "入力待ち" "Purr"
    ;;
  "stop")
    transcript=$(echo "$input" | jq -r '.transcript_path // empty')
    if has_running_subagents "${transcript}"; then
      exit 0
    fi
    send_notification "タスク完了" "Glass"
    ;;
  "error")
    send_notification "エラーで停止" "Ping"
    ;;
  *)
    send_notification "通知" ""
    ;;
esac
