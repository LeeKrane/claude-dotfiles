#!/usr/bin/env bash
in=$(cat)
case $(jq -r '.tool_input.subagent_type // ""' <<<"$in") in
  Explore|Plan|claude-code-guide|statusline-setup|*investigator|*reviewer) exit 0 ;;
esac
[ "$(jq -r '.tool_input.isolation // ""' <<<"$in")" = remote ] && exit 0
jq -e '.tool_input.prompt | test("follow ponytail"; "i")' <<<"$in" >/dev/null && exit 0
jq -c '{hookSpecificOutput:{hookEventName:"PreToolUse",updatedInput:(.tool_input | .prompt += "\n\nFollow ponytail: smallest complete change, reuse existing code, no unrequested features, abstractions or comments, one small check for new logic; end by naming what you skipped unless the task fixes the reply format.")}}' <<<"$in"
