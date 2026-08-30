#!/bin/bash
# Combined Claude Code status line.
# Shows: model name | "ctx" context-window fill bar with merged token count |
#        5h rate-limit bar + reset time | 7d rate limit.
#
# NOTE: the "ctx" segment (`.context_window.used_percentage` +
# `.context_window.total_input_tokens`/`.context_window.context_window_size`)
# is how full the model's context window is THIS turn — it is NOT the
# Claude.ai account rate limit. The account limits are the separate
# `5h [bar] NN%` / `7d:NN%` segments, sourced from
# `.rate_limits.five_hour.used_percentage` / `.rate_limits.seven_day.used_percentage`.
# Keep these visually distinct (the "ctx" prefix exists specifically to
# prevent that mixup) — a prior version omitted the 5h segment entirely and
# users mistook the ctx bar for session/rate-limit usage as a result.
#
# NOTE: no caveman-plugin badge here by request — caveman mode is always
# active for this user, so the badge added no information. If that changes,
# re-add via the caveman plugin's own hook script (see plugin cache under
# ~/.claude/plugins/cache/caveman/) rather than reinventing its logic.
#
# NOTE: an "elapsed session time" segment was requested but is NOT
# implemented — the statusLine stdin JSON schema has no session-start
# timestamp field to derive it from (checked: session_id, session_name,
# prompt_id, transcript_path, cwd, model, workspace, version, output_style,
# context_window, effort, thinking, rate_limits, vim, agent, pr, worktree —
# none of these carry a start time). Revisit if/when Claude Code exposes one.
#
# Wired via ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash ~/.claude/statusline-command.sh" }
#
# Regenerate/edit this file with the "statusline-setup" agent for any future changes.

input=$(cat)

# --- model name -----------------------------------------------------------
model=$(printf '%s' "$input" | jq -r '.model.display_name // "unknown"')

# NOTE: git branch/worktree segment removed by request — statusline no
# longer scopes or shows repository state.

# --- context window usage --------------------------------------------------
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
input_tokens=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // 0')
window_size=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // 0')

fmt_k() {
  local n="$1"
  case "$n" in
    ''|null) echo "0K"; return ;;
  esac
  awk -v n="$n" 'BEGIN { printf "%dK", (n/1000)+0.5 }'
}

tokens_str="$(fmt_k "$input_tokens")/$(fmt_k "$window_size")"

# color-by-severity helper (shared by every bar/percentage segment):
# muted green below 50%, muted gold 50-79%, muted red 80%+.
severity_color() {
  local pct_int="$1"
  if [ "$pct_int" -ge 80 ]; then
    echo 203 # muted red
  elif [ "$pct_int" -ge 50 ]; then
    echo 179 # muted gold
  else
    echo 108 # muted green
  fi
}

# render an N-segment █/░ bar for a given 0-100 integer percentage
render_bar() {
  local pct_int="$1" segments="$2"
  local filled=$(( pct_int * segments / 100 ))
  local empty=$(( segments - filled ))
  local bar=""
  [ "$filled" -gt 0 ] && bar=$(printf '%0.s█' $(seq 1 "$filled"))
  [ "$empty" -gt 0 ] && bar="$bar$(printf '%0.s░' $(seq 1 "$empty"))"
  printf '%s' "$bar"
}

BAR_SEGMENTS=10

# ctx bar merged with the token count, e.g. ctx [████░░░░░░] 6% (58K/1000K)
ctx_bar=$(render_bar 0 "$BAR_SEGMENTS")
ctx_pct_display="--"
ctx_color=108 # muted green
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  ctx_pct_int=$(awk -v p="$used_pct" 'BEGIN { v=p+0.5; if (v>100) v=100; if (v<0) v=0; printf "%d", v }')
  ctx_bar=$(render_bar "$ctx_pct_int" "$BAR_SEGMENTS")
  ctx_pct_display="${ctx_pct_int}%"
  ctx_color=$(severity_color "$ctx_pct_int")
fi
# "ctx" prefix keeps this visually/semantically distinct from the 5h/7d
# account rate-limit segments below — this is context-window fill, not
# account usage. Do not drop the prefix.
context_str=$(printf '\033[38;5;%dmctx [%s] %s (%s)\033[0m' "$ctx_color" "$ctx_bar" "$ctx_pct_display" "$tokens_str")

model_str=$(printf '\033[2m%s\033[0m' "$model")

# --- 5-hour / 7-day account rate limit usage --------------------------------
# `.rate_limits.*` is only present for Claude.ai subscribers after the first
# API response, so each segment is omitted entirely (not a "--" placeholder)
# when absent. Field paths verified against the statusLine stdin schema:
#   .rate_limits.five_hour.used_percentage
#   .rate_limits.seven_day.used_percentage
five_hour_pct=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_str=""
if [ -n "$five_hour_pct" ] && [ "$five_hour_pct" != "null" ]; then
  fh_int=$(awk -v p="$five_hour_pct" 'BEGIN { v=p+0.5; if (v>100) v=100; if (v<0) v=0; printf "%d", v }')
  fh_color=$(severity_color "$fh_int")
  fh_bar=$(render_bar "$fh_int" "$BAR_SEGMENTS")
  # `.rate_limits.five_hour.resets_at` = unix epoch seconds when the 5h
  # window resets; render local wall-clock time (e.g. "3:45pm").
  fh_resets_at=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
  fh_reset_str=""
  if [ -n "$fh_resets_at" ] && [ "$fh_resets_at" != "null" ]; then
    fh_reset_time=$(LC_TIME=C date -d "@$fh_resets_at" '+%H:%M' 2>/dev/null)
    [ -n "$fh_reset_time" ] && fh_reset_str=" resets $fh_reset_time"
  fi
  five_hour_str=$(printf '\033[38;5;%dm5h [%s] %d%%%s\033[0m' "$fh_color" "$fh_bar" "$fh_int" "$fh_reset_str")
fi

seven_day_pct=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_str=""
if [ -n "$seven_day_pct" ] && [ "$seven_day_pct" != "null" ]; then
  sd_int=$(awk -v p="$seven_day_pct" 'BEGIN { v=p+0.5; if (v>100) v=100; if (v<0) v=0; printf "%d", v }')
  sd_color=$(severity_color "$sd_int")
  seven_day_str=$(printf '\033[38;5;%dm7d:%d%%\033[0m' "$sd_color" "$sd_int")
fi

# --- assemble ---------------------------------------------------------------
out=""
for part in "$model_str" "$context_str" "$five_hour_str" "$seven_day_str"; do
  [ -z "$part" ] && continue
  if [ -z "$out" ]; then
    out="$part"
  else
    out="$out | $part"
  fi
done

printf '%s\n' "$out"
