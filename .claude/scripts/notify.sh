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
#     - cwd               : カレントディレクトリ (セッション名が取れない場合の表示に使用)
#     - notification_type : 通知種別 ("permission_prompt" | "idle_prompt" | "stop" | "error")
#     - transcript_path   : セッションの transcript (stop 時のサブエージェント実行中判定に使用)
#     - session_id        : セッション ID (通知のグループ化に使用)
#
# 通知種別 (括弧内は通知に表示するステータス):
#   permission_prompt : ツール実行の許可待ち [待機] (サウンド: Ping)
#   idle_prompt       : ユーザー入力待ち     [待機] (サウンド: Purr)
#   stop              : タスク完了           [完了] (サウンド: Glass)
#   error             : エラーで停止         [停止] (サウンド: Ping) ※ StopFailure フック
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
# NOTE VS Code 統合ターミナルで実行している場合、通知クリックで該当ターミナルタブまで
#   フォーカスする。拡張 jackywjs.focus-terminal (J-Skills Terminal Focus) が必要。
#   詳細は vscode_focus_command 参照。
#

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
[[ -z "${cwd}" ]] && cwd=$PWD
project=$(basename "$cwd")
notification_type=$(echo "$input" | jq -r '.notification_type')
session_id=$(echo "$input" | jq -r '.session_id // empty')

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

# 通知クリック時に VS Code の該当ターミナルタブへフォーカスするコマンドを組み立てる。
#
# VS Code には「特定のターミナルタブをフォーカスする」外部 API / CLI が存在しないため、
# 拡張 jackywjs.focus-terminal (J-Skills Terminal Focus) の URI ハンドラを経由する。
# 拡張は Terminal.processId が一致するタブを探して show() する。
# 同等の自作版が ~/Repositories/vscode-focus-terminal にある (URI を 1 行戻せば切替可能)。
#
# 経路: TMUX_PANE → tmux セッション → attach 中のクライアント → その親プロセス
#       = VS Code 統合ターミナルのシェル PID = Terminal.processId
# claude は tmux サーバの子なので親子関係が切れている。クライアント側から辿り直す。
#
# NOTE URI は VS Code が選んだ 1 ウィンドウにしか配送されない。対象タブが別ウィンドウに
#   あると空振りするため、先に該当ウィンドウを前面化する。ワークスペースルートは
#   ~/.claude/ide/*.lock から cwd で逆引きする。
#   `code` CLI ではなく `open -a` を使うのは、前者が Electron を Node モードで起動して
#   Dock にアイコンが一瞬増えるため。`open -a` は LaunchServices 経由で既存プロセスに
#   イベントを送るだけで済む。
#
# NOTE detach 中の tmux セッションはタブが存在しないので特定できない。この場合と
#   VS Code 以外の端末 (iTerm2 等) の場合は失敗を返し、-activate にフォールバックする。
vscode_focus_command() {
  local sess client_pid shell_pid parent ws
  [[ -n "${TMUX_PANE}" ]] || return 1

  sess=$(tmux display-message -p -t "${TMUX_PANE}" '#{session_id}' 2>/dev/null) || return 1
  client_pid=$(tmux list-clients -t "${sess}" -F '#{client_pid}' 2>/dev/null | head -1)
  [[ -n "${client_pid}" ]] || return 1

  shell_pid=$(ps -o ppid= -p "${client_pid}" 2>/dev/null | tr -d ' ')
  [[ -n "${shell_pid}" ]] || return 1

  # 統合ターミナルのシェルは VS Code のヘルパプロセスの子になる
  parent=$(ps -o comm= -p "$(ps -o ppid= -p "${shell_pid}" 2>/dev/null | tr -d ' ')" 2>/dev/null)
  [[ "${parent}" == *"Visual Studio Code"* ]] || return 1

  ws=$(jq -r --arg c "${cwd}" '.workspaceFolders[]? | select($c == . or ($c | startswith(. + "/")))' \
        "${HOME}"/.claude/ide/*.lock 2>/dev/null | head -1)

  # -execute は最小 PATH の /bin/sh で実行されるため絶対パスで指定する
  printf "%s" "/usr/bin/open -a 'Visual Studio Code' '${ws:-${cwd}}'; /usr/bin/open 'vscode://jackywjs.focus-terminal/focus?pid=${shell_pid}'"
}

# 表示は「Claude Code」/「[ステータス] セッション名」の 2 行。セッション名には tmux の
# pane_title (Claude Code が会話の要約を設定する) を使い、取れなければプロジェクト名に落とす。
#
# NOTE terminal-notifier は `[` で始まる値を引数として認識せず捨てる (-help に記載)。
#   `\[` とエスケープすること。忘れると Message が空になったり、-title が既定値の
#   "Terminal" に化けたりする。
send_notification() {
  local status="$1"
  local sound="$2"
  local session
  local args
  local focus

  session=$(tmux display-message -p -t "${TMUX_PANE}" '#{pane_title}' 2>/dev/null)
  args=(-title "Claude Code" -message "\[${status}] ${session:-${project}}")

  [[ -n "${sound}" ]] && args+=(-sound "${sound}")
  # セッション単位でグループ化する。同一セッションの古い通知だけが置き換わり、
  # 別セッションの通知は残る。
  [[ -n "${session_id}" ]] && args+=(-group "claude-code-${session_id}")

  focus=$(vscode_focus_command)
  if [[ -n "${focus}" ]]; then
    args+=(-execute "${focus}")
  elif [[ -n "${BUNDLE_ID}" ]]; then
    args+=(-activate "${BUNDLE_ID}")
  fi

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
# ただし完了通知の <task-notification> は dequeue 後に user エントリ (string content)
# としても再挿入されるため、ユーザーメッセージ扱いにしない (リセットすると
# 実行中の残りエージェントの記録が消え、抑制が効かなくなる)。
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
         and (($e.message.content | tostring | startswith("<task-notification>")) | not)
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
    send_notification "待機" "Ping"
    ;;
  "idle_prompt")
    # send_notification "待機" "Purr"
    ;;
  "stop")
    transcript=$(echo "$input" | jq -r '.transcript_path // empty')
    if has_running_subagents "${transcript}"; then
      exit 0
    fi
    send_notification "完了" "Glass"
    ;;
  "error")
    send_notification "停止" "Ping"
    ;;
  *)
    send_notification "通知" ""
    ;;
esac
