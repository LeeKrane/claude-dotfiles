#!/usr/bin/env bash
# SessionStart hook: stop claude-mem from pausing itself near a subscription limit.
#
# claude-mem's worker aborts the observer at 92-95% of a Claude usage window and
# then waits 30 minutes before it retries. With several subscriptions to switch
# between, that pause is wrong. This patch:
#   - raises the utilization thresholds and the 5-hour grace buffer above 100%,
#     so only a real "rejected" status from the provider stops the observer;
#   - cuts the cooldown after a rejection from 30 to 2 minutes, so the retry
#     picks up the account you switched to.
# The patterns match values, not minified names, so they survive plugin updates.
# A build that no longer matches is left alone. The worker restarts only when a
# file changed.

root="${CLAUDE_MEM_PATCH_ROOT:-$HOME/.claude/plugins/cache}"
ident='[A-Za-z_$][A-Za-z0-9_$]*'
thresholds='\{five_hour:\.[0-9]+,seven_day_opus:\.[0-9]+,seven_day_sonnet:\.[0-9]+,seven_day:\.[0-9]+,overage:\.[0-9]+\}'
grace="(=900\\*1e3,${ident}=)\\.[0-9]+"
cooldown="(${ident}=)30\\*6e4,(${ident}=5\\*6e4,)"

changed=0
for f in "$root"/*/claude-mem/*/scripts/worker-service.cjs; do
  [ -f "$f" ] || continue
  grep -qE "$thresholds|$grace|$cooldown" "$f" || continue
  tmp=$(mktemp) || continue
  if sed -E \
    -e "s/$thresholds/{five_hour:2,seven_day_opus:2,seven_day_sonnet:2,seven_day:2,overage:2}/" \
    -e "s/$grace/\\12/" \
    -e "s/$cooldown/\\12*6e4,\\2/" \
    "$f" > "$tmp"; then
    command cat "$tmp" > "$f" && changed=1 && echo "patched $f"
  fi
  rm -f "$tmp"
done

if [ "$changed" = 1 ] && [ -z "$CLAUDE_MEM_PATCH_NO_RESTART" ]; then
  port=$(jq -r '.CLAUDE_MEM_WORKER_PORT // "37700"' "$HOME/.claude-mem/settings.json" 2>/dev/null || echo 37700)
  curl -s -m 3 -X POST "http://127.0.0.1:${port:-37700}/api/admin/restart" >/dev/null 2>&1
fi
exit 0
