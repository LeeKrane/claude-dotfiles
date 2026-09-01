#!/bin/bash
# Combined Claude Code status line.
# Shows: model name | "ctx" context-window fill bar |
#        5h rate-limit bar + reset time | 7d rate limit + reset weekday/time |
#        prompt-cache freshness (flame/snowflake).
#
# Example output:
#   Fable | ctx [█░░░░░░░░░] 12% | 5h [██░░░░░░░░] 23% ↻ 15:00 | 7d: 41% ↻ Do 15:00 | 󰈸
#
# NOTE: the "ctx" segment (`.context_window.used_percentage`) is how full the
# model's context window is THIS turn — it is NOT the Claude.ai account rate
# limit. The account limits are the separate `5h [bar] NN%` / `7d: NN%`
# segments, sourced from `.rate_limits.five_hour.used_percentage` /
# `.rate_limits.seven_day.used_percentage`. Keep these visually distinct (the
# "ctx" prefix exists specifically to prevent that mixup) — a prior version
# omitted the 5h segment entirely and users mistook the ctx bar for
# session/rate-limit usage as a result.
#
# NOTE: both reset-time labels (5h and 7d) use the same "↻ " icon+space
# prefix, not the word "resets", for visual consistency and terseness.
#
# NOTE: the 7d segment appends its reset time as weekday + local %H:%M, e.g.
# "↻ Do 15:00", sourced from `.rate_limits.seven_day.resets_at` (unix epoch
# seconds — verified against the official statusline docs at
# code.claude.com/docs/en/statusline.md). Weekday uses a locale-independent
# German 2-letter mapping (`weekday_de`, driven by `date +%u` 1..7 → Mo Di Mi
# Do Fr Sa So) rather than `date +%a`, which would follow system locale. If
# the reset falls on today's calendar date, the weekday is dropped (mirrors
# the 5h segment's plain time-only format): "↻ 15:00". If resets_at is
# absent, the segment falls back to a bare "7d: NN%".
#
# NOTE: the 7d segment's color is pace-aware, not just raw-percentage-based
# like ctx/5h. A raw percentage is misleading on a 7-day window — 41% used
# with 6 days left to reset is fine, but 41% used one day into the window is
# a crisis. The color is max(raw severity, pace severity), where pace =
# used_pct / (elapsed_fraction_of_window * 100); pace >=1.5 is red, >=1.1 is
# gold. Pace is skipped (raw severity only) when the window just reset
# (elapsed_fraction < 0.05) or resets_at is absent, since the ratio explodes
# near zero elapsed time. See the `sd_color` awk block below.
#
# NOTE: `.rate_limits.spend_limit.*` also exists in the schema (gateway-only,
# not applicable to Claude.ai subscribers) but is deliberately NOT rendered
# here — out of scope for this statusline, not a missing feature.
#
# NOTE: the last segment shows prompt-cache freshness, sourced from
# `.prompt_cache.{warm,ttl,expires_at}` (requires Claude Code >=2.1.251).
# Green flame = warm and not close to expiring; gold flame + minutes
# (e.g. "4m") = warm but expiring soon (remaining time <= 25% of the TTL,
# 5m or 1h); muted-blue snowflake = cold. The flame is Nerd Font glyph
# U+F0238, so it needs a Nerd Font in the terminal to render correctly. The
# whole segment self-omits (no placeholder) when `.prompt_cache` is absent
# from stdin — older Claude Code, or before the first API response.
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

# --- single jq call: extract every field this script needs at once --------
# Fields (in order): model display name, ctx used%, 5h used%, 5h resets_at,
# 7d used%, 7d resets_at, prompt-cache warm flag, prompt-cache ttl,
# prompt-cache expires_at. Joined on the ASCII unit separator (0x1f) so
# `IFS=$'\x1f' read` can split them back out below. Absent fields become
# empty strings (`// ""`), so downstream guards are plain `[ -n "$var" ]`
# checks rather than `!= "null"` comparisons. `map(tostring)` also turns the
# `.prompt_cache.warm` boolean into the literal strings "true"/"false", so it
# can be compared like any other field via plain `[ "$cache_warm" = "true" ]`.
# NB: `.warm` uses an explicit null check instead of `//` — jq's `//` treats
# `false` itself as absent, which would make a cold cache indistinguishable
# from a missing field.
IFS=$'\x1f' read -r model used_pct five_hour_pct fh_resets_at seven_day_pct sd_resets_at \
  cache_warm cache_ttl cache_expires_at <<EOF
$(printf '%s' "$input" | jq -r '[
  (.model.display_name // "unknown"),
  (.context_window.used_percentage // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.rate_limits.seven_day.resets_at // ""),
  (if .prompt_cache.warm == null then "" else .prompt_cache.warm end),
  (.prompt_cache.ttl // ""),
  (.prompt_cache.expires_at // "")
] | map(tostring) | join("")')
EOF

# NOTE: git branch/worktree segment removed by request — statusline no
# longer scopes or shows repository state.

# German 2-letter weekday abbreviation for an epoch-seconds timestamp.
# Locale-independent (does not rely on system LC_TIME / `date +%a`).
weekday_de() {
  case "$(date -d "@$1" '+%u')" in
    1) echo Mo ;; 2) echo Di ;; 3) echo Mi ;; 4) echo Do ;;
    5) echo Fr ;; 6) echo Sa ;; 7) echo So ;;
  esac
}

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

# ctx bar, e.g. ctx [████░░░░░░] 6%
ctx_bar=$(render_bar 0 "$BAR_SEGMENTS")
ctx_pct_display="--"
ctx_color=108 # muted green
if [ -n "$used_pct" ]; then
  ctx_pct_int=$(awk -v p="$used_pct" 'BEGIN { v=p+0.5; if (v>100) v=100; if (v<0) v=0; printf "%d", v }')
  ctx_bar=$(render_bar "$ctx_pct_int" "$BAR_SEGMENTS")
  ctx_pct_display="${ctx_pct_int}%"
  ctx_color=$(severity_color "$ctx_pct_int")
fi
# "ctx" prefix keeps this visually/semantically distinct from the 5h/7d
# account rate-limit segments below — this is context-window fill, not
# account usage. Do not drop the prefix.
context_str=$(printf '\033[38;5;%dmctx [%s] %s\033[0m' "$ctx_color" "$ctx_bar" "$ctx_pct_display")

model_str=$(printf '\033[2m%s\033[0m' "$model")

# --- 5-hour / 7-day account rate limit usage --------------------------------
# `.rate_limits.*` is only present for Claude.ai subscribers after the first
# API response, so each segment is omitted entirely (not a "--" placeholder)
# when absent. Field paths verified against the statusLine stdin schema:
#   .rate_limits.five_hour.used_percentage / .resets_at
#   .rate_limits.seven_day.used_percentage / .resets_at
five_hour_str=""
if [ -n "$five_hour_pct" ]; then
  fh_int=$(awk -v p="$five_hour_pct" 'BEGIN { v=p+0.5; if (v>100) v=100; if (v<0) v=0; printf "%d", v }')
  fh_color=$(severity_color "$fh_int")
  fh_bar=$(render_bar "$fh_int" "$BAR_SEGMENTS")
  # `.rate_limits.five_hour.resets_at` = unix epoch seconds when the 5h
  # window resets; render local wall-clock time (e.g. "15:45").
  fh_reset_str=""
  if [ -n "$fh_resets_at" ]; then
    fh_reset_time=$(LC_TIME=C date -d "@$fh_resets_at" '+%H:%M' 2>/dev/null)
    [ -n "$fh_reset_time" ] && fh_reset_str=" ↻ $fh_reset_time"
  fi
  five_hour_str=$(printf '\033[38;5;%dm5h [%s] %d%%%s\033[0m' "$fh_color" "$fh_bar" "$fh_int" "$fh_reset_str")
fi

seven_day_str=""
if [ -n "$seven_day_pct" ]; then
  sd_int=$(awk -v p="$seven_day_pct" 'BEGIN { v=p+0.5; if (v>100) v=100; if (v<0) v=0; printf "%d", v }')

  # `.rate_limits.seven_day.resets_at` = unix epoch seconds when the 7d
  # window resets; render as "↻ <weekday> HH:MM", dropping the weekday if
  # the reset falls on today's calendar date (mirrors the 5h format).
  sd_reset_str=""
  if [ -n "$sd_resets_at" ]; then
    sd_reset_time=$(LC_TIME=C date -d "@$sd_resets_at" '+%H:%M' 2>/dev/null)
    if [ -n "$sd_reset_time" ]; then
      today_ymd=$(date '+%Y%m%d')
      reset_ymd=$(date -d "@$sd_resets_at" '+%Y%m%d' 2>/dev/null)
      if [ "$reset_ymd" = "$today_ymd" ]; then
        sd_reset_str=" ↻ $sd_reset_time"
      else
        sd_reset_str=" ↻ $(weekday_de "$sd_resets_at") $sd_reset_time"
      fi
    fi
  fi

  # Pace-aware color: raw percent alone is misleading on a 7-day window (41%
  # used with 6 days left is fine; 41% one day in is a crisis). Take
  # max(raw severity, pace severity), where pace = used% / (elapsed% of the
  # window). Pace is skipped (raw severity only) when the window just reset
  # (elapsed_fraction < 0.05) or resets_at is unknown, since the ratio
  # explodes near zero elapsed time.
  now_epoch=$(date +%s)
  sd_color=$(awk -v pct="$sd_int" -v resets_at="${sd_resets_at:-}" -v now="$now_epoch" '
    function severity(p) {
      if (p >= 80) return 203
      if (p >= 50) return 179
      return 108
    }
    BEGIN {
      raw = severity(pct)
      best = raw
      if (resets_at != "") {
        remaining = resets_at - now
        elapsed_fraction = (604800 - remaining) / 604800
        if (elapsed_fraction >= 0.05) {
          pace = pct / (elapsed_fraction * 100)
          if (pace >= 1.5) pace_c = 203
          else if (pace >= 1.1) pace_c = 179
          else pace_c = 108
          if (pace_c > best) best = pace_c
        }
      }
      print best
    }
  ')

  seven_day_str=$(printf '\033[38;5;%dm7d: %d%%%s\033[0m' "$sd_color" "$sd_int" "$sd_reset_str")
fi

# --- prompt-cache freshness --------------------------------------------------
# `.prompt_cache.{warm,ttl,expires_at}` requires Claude Code >=2.1.251; the
# segment self-omits entirely (no placeholder) when `.prompt_cache.warm` is
# absent, i.e. older Claude Code or before the first API response. States:
#   warm, not expiring soon -> green flame (color 108)
#   warm, expiring soon     -> gold flame + minutes remaining (color 179),
#                              e.g. "4m"; "expiring soon" = remaining time
#                              <= 25% of the cache TTL (5m -> 75s, 1h -> 900s)
#   cold (or remaining <=0) -> muted-blue snowflake (color 110)
# The flame is the Nerd Font glyph U+F0238 (nf-md-fire) — requires a Nerd
# Font in the terminal to render; falls back to a box/blank glyph otherwise.
cache_str=""
if [ -n "$cache_warm" ]; then
  if [ "$cache_warm" = "true" ]; then
    ttl_secs=300
    [ "$cache_ttl" = "1h" ] && ttl_secs=3600
    expiring=0
    remaining=""
    if [ -n "$cache_expires_at" ]; then
      cache_now=$(date +%s)
      remaining=$(( cache_expires_at - cache_now ))
      if [ "$remaining" -le 0 ]; then
        cache_warm="false" # treat as cold below
      elif [ "$remaining" -le $(( ttl_secs / 4 )) ]; then
        expiring=1
      fi
    fi
    if [ "$cache_warm" = "true" ]; then
      if [ "$expiring" -eq 1 ]; then
        cache_minutes=$(( (remaining + 59) / 60 ))
        [ "$cache_minutes" -lt 1 ] && cache_minutes=1
        cache_str=$(printf '\033[38;5;179m\Uf0238 %dm\033[0m' "$cache_minutes")
      else
        cache_str=$(printf '\033[38;5;108m\Uf0238\033[0m')
      fi
    fi
  fi
  [ "$cache_warm" = "false" ] && cache_str=$(printf '\033[38;5;110m❄\033[0m')
fi

# --- assemble ---------------------------------------------------------------
out=""
for part in "$model_str" "$context_str" "$five_hour_str" "$seven_day_str" "$cache_str"; do
  [ -z "$part" ] && continue
  if [ -z "$out" ]; then
    out="$part"
  else
    out="$out | $part"
  fi
done

printf '%s\n' "$out"
