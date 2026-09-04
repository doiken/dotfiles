# Read JSON input from stdin
input=$(cat)

MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // empty')

# セッションID (グレー表示。--resume や /cherry-pick に使う)
SESSION_ID=$(echo "$input" | jq -r '.session_id // empty')
ID_SEG=""
if [ -n "$SESSION_ID" ]; then
  ID_SEG=$(printf ' | 🆔 %b%s%b' '\033[90m' "$SESSION_ID" '\033[0m')
fi

# このセッションでの compaction 回数 (transcript に isCompactSummary:true の行が残る)
COMPACT_SEG=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  compact_count=$(grep -c '"isCompactSummary":true' "$TRANSCRIPT_PATH" 2>/dev/null)
  if [ "${compact_count:-0}" -gt 0 ]; then
    COMPACT_SEG=" | ⇄${compact_count}"
  fi
fi

# レート制限利用率 (5時間枠/週次枠)。最初のAPIレスポンスまでは存在しないので非表示
RATE_SEG=""
# 利用率に応じた色付き "xx%" を返す
rate_pct() {
  local pct=${1%.*}
  local color="\033[32m"  # Green
  if [ "$pct" -ge 80 ]; then
    color="\033[31m"  # Red
  elif [ "$pct" -ge 65 ]; then
    color="\033[33m"  # Yellow
  fi
  printf '%b%s%%%b' "$color" "$pct" '\033[0m'
}

five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
if [ -n "$five_h" ] && [ -n "$week" ]; then
  five_h_at=""
  week_at=""
  if [ -n "$five_h_reset" ]; then
    five_h_at="~$(date -r "$five_h_reset" +%H:%M)"
  fi
  if [ -n "$week_reset" ]; then
    week_at="~$(date -r "$week_reset" +%-m/%-d)"
  fi
  RATE_SEG=" | ⏱ ${five_h_at}($(rate_pct "$five_h")) ${week_at}($(rate_pct "$week"))"
fi

# Get git branch information
GIT_BRANCH=""
if git rev-parse &>/dev/null; then
  BRANCH=$(git branch --show-current)
  if [ -n "$BRANCH" ]; then
    GIT_BRANCH=" | $BRANCH"
  else
    COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null)
    if [ -n "$COMMIT_HASH" ]; then
      GIT_BRANCH=" | HEAD ($COMMIT_HASH)"
    fi
  fi
fi

# Get token summary from context_window (v2.1.132+ で compaction 反映済みの値が渡される)
total_tokens=$(echo "$input" | jq -r '.context_window | (.total_input_tokens // 0) + (.total_output_tokens // 0)' 2>/dev/null)
percentage=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)

if [ -z "$percentage" ]; then
  TOKEN_COUNT="_ tkns. (_%)"
else
  percentage=${percentage%.*}

  # Format token display
  if [ "$total_tokens" -ge 1000 ]; then
    thousands=$(echo "scale=1; $total_tokens/1000" | bc)
    token_display=$(printf "%.1fK" "$thousands")
  else
    token_display="$total_tokens"
  fi

  # Color coding for percentage (auto-compact の既定閾値 85% (autoCompactWindow) の直前の 80% で赤)
  if [ "$percentage" -ge 80 ]; then
    color="\033[31m"  # Red
  elif [ "$percentage" -ge 65 ]; then
    color="\033[33m"  # Yellow
  else
    color="\033[32m"  # Green
  fi

  # Format: "123 tkns. (10%)"
  TOKEN_COUNT=$(printf '%s tkns. (%b%s%%%b)' "$token_display" "$color" "$percentage" '\033[0m')
fi

# echo "🤖 ${MODEL_DISPLAY} | 📁 ${CURRENT_DIR##*/}${GIT_BRANCH} | 💰️ ${TOKEN_COUNT}"
echo "🤖 ${MODEL_DISPLAY} | 📁 ${CURRENT_DIR##*/} | 💰️ ${TOKEN_COUNT}${COMPACT_SEG}${RATE_SEG}${ID_SEG}"
