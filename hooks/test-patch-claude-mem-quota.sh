#!/usr/bin/env bash
# Tests for patch-claude-mem-quota.sh against a fake plugin cache.
hook="$(dirname "$0")/patch-claude-mem-quota.sh"
fail=0
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT
f="$root/thedotmack/claude-mem/9.9.9/scripts/worker-service.cjs"
mkdir -p "$(dirname "$f")"
orig='var SGe={five_hour:.95,seven_day_opus:.93,seven_day_sonnet:.92,seven_day:.93,overage:.95},One=900*1e3,wGe=.85;x();var _C=30*6e4,O3e=5*6e4,Xc=new Map;var other=30*6e4;'
want='var SGe={five_hour:2,seven_day_opus:2,seven_day_sonnet:2,seven_day:2,overage:2},One=900*1e3,wGe=2;x();var _C=2*6e4,O3e=5*6e4,Xc=new Map;var other=30*6e4;'
printf '%s' "$orig" > "$f"

run() { CLAUDE_MEM_PATCH_ROOT="$root" CLAUDE_MEM_PATCH_NO_RESTART=1 bash "$hook"; }
check() { if [ "$2" != "$3" ]; then echo "FAIL $1"; echo "  want: $3"; echo "  got:  $2"; fail=1; fi; }

out=$(run)
check "patches thresholds, grace buffer and cooldown" "$(command cat "$f")" "$want"
check "reports patched file" "$out" "patched $f"

out=$(run)
check "idempotent on second run" "$(command cat "$f")" "$want"
check "silent when nothing to patch" "$out" ""

printf 'unrelated content' > "$f"
run >/dev/null
check "leaves unknown builds alone" "$(command cat "$f")" "unrelated content"

CLAUDE_MEM_PATCH_ROOT="$root/missing" CLAUDE_MEM_PATCH_NO_RESTART=1 bash "$hook"
check "exits 0 without claude-mem installed" "$?" "0"

[ $fail = 0 ] && echo "ALL PASS"
exit $fail
