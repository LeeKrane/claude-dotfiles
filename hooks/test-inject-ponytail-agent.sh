#!/usr/bin/env bash
hook="$(dirname "$0")/inject-ponytail-agent.sh"
fail=0
run() { jq -n --arg t "$1" --arg p "$2" --arg i "$3" '{tool_name:"Agent",tool_input:({subagent_type:$t,prompt:$p,description:"d"} + (if $i != "" then {isolation:$i} else {} end))}' | bash "$hook" 2>/dev/null; }
check() {
  local want=$1 type=$2 prompt=$3 iso=${4:-} out rc
  out=$(run "$type" "$prompt" "$iso"); rc=$?
  [ $rc = 0 ] || { echo "FAIL exit $rc: $type"; fail=1; return; }
  case $want in
    inject)
      jq -e --arg p "$prompt" '.hookSpecificOutput | .hookEventName == "PreToolUse" and (has("permissionDecision") | not) and (.updatedInput.prompt | startswith($p) and endswith("unless the task fixes the reply format.")) and .updatedInput.description == "d"' <<<"$out" >/dev/null || { echo "FAIL want inject: $type|$prompt|$iso"; fail=1; } ;;
    skip) [ -z "$out" ] || { echo "FAIL want skip: $type|$prompt|$iso"; fail=1; } ;;
  esac
}
check inject general-purpose 'implement x'
check inject '' 'implement x'
check inject claude 'implement x'
check inject general-purpose 'review require-ponytail.sh'
check inject general-purpose 'implement x' local
check skip Explore 'find x'
check skip Plan 'plan x'
check skip caveman:cavecrew-investigator 'find x'
check skip caveman:cavecrew-reviewer 'review x'
check skip general-purpose 'implement x, Follow Ponytail.'
check skip general-purpose 'implement x' remote
[ $fail = 0 ] && echo "ALL PASS"
exit $fail
