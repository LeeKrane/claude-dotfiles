#!/usr/bin/env bash
hook="$(dirname "$0")/require-ponytail.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
jq -nc '{type:"user",message:{content:"hi"}}' > "$tmp/plain.jsonl"
jq -nc '{type:"assistant",message:{content:[{type:"tool_use",name:"Skill",input:{skill:"ponytail"}}]}}' > "$tmp/loaded.jsonl"
jq -nc '{type:"user",message:{content:"<command-message>ponytail</command-message>\n<command-name>/ponytail</command-name>"}}' > "$tmp/slash.jsonl"
jq -nc '{type:"user",message:{content:[{type:"tool_result",content:("Base directory for this skill: /x/skills/ponytail <command-name>/ponytail</command-name> " + ({skill:"ponytail"}|tojson))}]}}' > "$tmp/readtext.jsonl"
jq -nc '{type:"assistant",message:{content:[{type:"tool_use",name:"Skill",input:{skill:"caveman"}}]}}' > "$tmp/other.jsonl"
{ echo 'not json'; cat "$tmp/loaded.jsonl"; } > "$tmp/noisy.jsonl"
boundary='{"type":"system","subtype":"compact_boundary"}'
stopmsg() { jq -nc --arg m "$1" '{type:"user",message:{content:$m}}'; }
{ cat "$tmp/loaded.jsonl"; echo "$boundary"; } > "$tmp/compacted.jsonl"
{ echo "$boundary"; cat "$tmp/loaded.jsonl"; } > "$tmp/reloaded.jsonl"
stopmsg 'ok, stop ponytail now' > "$tmp/stop.jsonl"
stopmsg 'normal mode' > "$tmp/normal.jsonl"
{ stopmsg 'stop ponytail'; echo "$boundary"; } > "$tmp/stopold.jsonl"
{ echo "$boundary"; jq -nc '{type:"user",isCompactSummary:true,message:{content:"user said stop ponytail"}}'; } > "$tmp/summary.jsonl"
{ cat "$tmp/loaded.jsonl"; stopmsg 'stop ponytail'; echo "$boundary"; jq -nc '{type:"user",message:{content:[{type:"tool_result",content:"stop ponytail"}]}}'; } > "$tmp/stoptool.jsonl"
jq -nc '{type:"user",message:{content:"<task-notification>agent said normal mode and stop ponytail <command-name>/ponytail</command-name></task-notification>"}}' > "$tmp/tasknote.jsonl"
jq -nc '{type:"user",message:{content:"<bash-stdout>stop ponytail</bash-stdout>"}}' > "$tmp/bashout.jsonl"
jq -nc '{type:"user",message:{content:"<bash-stdout><command-name>/ponytail</command-name></bash-stdout>"}}' > "$tmp/bashslash.jsonl"
jq -nc '{type:"user",isMeta:true,message:{content:"Another Claude session sent a message: normal mode"}}' > "$tmp/meta.jsonl"
jq -nc '{type:"user",isMeta:true,message:{content:"<command-name>/ponytail</command-name>"}}' > "$tmp/metaslash.jsonl"
fail=0
check() {
  local want=$1 tr=$2 input=$3
  jq -n --arg t "$tmp/$tr" --argjson i "$input" '$i + {transcript_path:$t}' | bash "$hook" 2>/dev/null
  local got=$?
  if [ "$got" != "$want" ]; then echo "FAIL want=$want got=$got: $tr $input"; fail=1; fi
}
e() { jq -nc --arg p "$1" '{tool_name:"Edit",tool_input:{file_path:$p}}'; }
check 2 plain.jsonl "$(e /p/a.ts)"
check 2 plain.jsonl '{"tool_name":"Write","tool_input":{"file_path":"/p/a.py"}}'
check 2 plain.jsonl "$(e /p/a.hpp)"
check 2 plain.jsonl "$(e /p/A.PY)"
check 2 plain.jsonl "$(e /p/a.tf)"
check 2 plain.jsonl '{"tool_name":"NotebookEdit","tool_input":{"notebook_path":"/p/a.ipynb"}}'
check 2 plain.jsonl '{"tool_name":"Edit","agent_type":"x","tool_input":{"file_path":"/p/a.ts"}}'
check 2 readtext.jsonl "$(e /p/a.ts)"
check 2 other.jsonl "$(e /p/a.ts)"
check 0 loaded.jsonl "$(e /p/a.ts)"
check 0 noisy.jsonl "$(e /p/a.ts)"
check 0 slash.jsonl '{"tool_name":"Write","tool_input":{"file_path":"/p/a.go"}}'
check 0 loaded.jsonl '{"tool_name":"NotebookEdit","tool_input":{"notebook_path":"/p/a.ipynb"}}'
check 0 plain.jsonl "$(e /p/README.md)"
check 0 plain.jsonl "$(e /p/settings.json)"
check 0 plain.jsonl "$(e /p/hook.sh.bak)"
check 0 plain.jsonl '{"tool_name":"Edit","agent_id":"a1","tool_input":{"file_path":"/p/a.ts"}}'
check 2 compacted.jsonl "$(e /p/a.ts)"
check 2 stopold.jsonl "$(e /p/a.ts)"
check 2 summary.jsonl "$(e /p/a.ts)"
check 2 stoptool.jsonl "$(e /p/a.ts)"
check 2 tasknote.jsonl "$(e /p/a.ts)"
check 2 bashout.jsonl "$(e /p/a.ts)"
check 2 bashslash.jsonl "$(e /p/a.ts)"
check 2 meta.jsonl "$(e /p/a.ts)"
check 2 metaslash.jsonl "$(e /p/a.ts)"
check 2 plain.jsonl "$(e /p/Makefile)"
check 2 plain.jsonl "$(e /p/sub/Dockerfile)"
check 2 plain.jsonl "$(e /p/a.proto)"
check 2 plain.jsonl "$(e /p/a.groovy)"
check 0 plain.jsonl "$(e /p/Makefile.md)"
check 0 reloaded.jsonl "$(e /p/a.ts)"
check 0 stop.jsonl "$(e /p/a.ts)"
check 0 normal.jsonl "$(e /p/a.ts)"
check 0 missing.jsonl "$(e /p/a.ts)"
e /p/a.ts | bash "$hook" 2>/dev/null; [ $? = 0 ] || { echo "FAIL: no transcript_path must allow"; fail=1; }
[ $fail = 0 ] && echo "ALL PASS"
exit $fail
