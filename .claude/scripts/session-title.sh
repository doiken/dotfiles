#!/bin/bash
#
# 自動生成タイトル (ai-title) を fullscreen TUI の入力欄の枠のラベルに反映する。
# UserPromptSubmit フックとして実行する。依存: jq
#
# tui=fullscreen における枠ラベルは transcript の {"type":"agent-name"} 。
# これが書かれるのは /rename ・ --name ・ フックの sessionTitle の3経路のみ。
# 自動生成タイトルは {"type":"ai-title"} を書くだけでこの経路に入らないため、
# 放っておくと枠に出ない。 
#
# 注意点:
#   - session_title があれば transcript を読まずに抜ける。確定後は Claude Code 側も
#     no-op になり、transcript の全読み (16MB で約 80ms) が完全に無駄になるため
#   - 必ず exit 0。UserPromptSubmit は終了コード 2 でプロンプト送信自体を止める
#   - タイトルが付くと ai-title の自動更新が止まるので、最初の1つで固定される
#   - 新規セッションでは ai-title 生成後、つまり2発目のプロンプトから反映される
#     (SessionStart にしないのは --resume 時しか既存の ai-title を拾えないため)
#
# 調査対象は Claude Code 2.1.236。
#

input=$(cat)

# タイトル確定済みなら transcript を読まずに抜ける
session_title=$(printf '%s' "$input" | jq -r '.session_title // empty')
if [ -n "$session_title" ]; then
  exit 0
fi

transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
  exit 0
fi

# 最後の ai-title エントリが最新のタイトル。-s は使わない (長い transcript を全部載せない)
ai_title=$(jq -r 'select(.type == "ai-title") | .aiTitle' "$transcript_path" 2>/dev/null | tail -1)
if [ -z "$ai_title" ]; then
  exit 0
fi

jq -n --arg title "$ai_title" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", sessionTitle: $title}}'

exit 0
