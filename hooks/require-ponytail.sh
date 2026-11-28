#!/usr/bin/env bash
in=$(cat)
[ -n "$(jq -r '.agent_id // empty' <<<"$in")" ] && exit 0
jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$in" \
  | grep -qiE '(\.(py|js|mjs|cjs|ts|tsx|jsx|mts|cts|rs|go|java|kt|cs|c|h|cc|cpp|cxx|hpp|rb|php|sh|bash|zsh|fish|lua|svelte|vue|astro|html|css|scss|less|nix|swift|sql|dart|scala|ex|exs|hs|pl|zig|tf|ps1|ipynb|groovy|proto|el|vim|kts|clj|jl)|/(Makefile|Dockerfile))$' || exit 0
tp=$(jq -r '.transcript_path // empty' <<<"$in")
[ -f "$tp" ] || exit 0
jq -Rn -e '[inputs | fromjson?] as $t
  | def at(f): $t | to_entries | map(select(.value | f)) | (last.key // -1);
  def text: (.type == "user" and .isCompactSummary != true and .isMeta != true and (.message.content | type) == "string");
  at(.type == "system" and .subtype == "compact_boundary") as $c
  | ([
      at(.type == "assistant" and any(.message.content[]?; .type == "tool_use" and .name == "Skill" and .input.skill == "ponytail")),
      at(text and (.message.content | startswith("<command-message>")) and (.message.content | test("<command-name>/?ponytail</command-name>"))),
      at(text and (.message.content | startswith("<") | not) and (.message.content | test("stop ponytail|normal mode"; "i")))
    ] | max) > $c' "$tp" >/dev/null 2>&1 && exit 0
echo "Blocked: load ponytail first, in its own call before the edit (Skill tool, skill: ponytail), then retry." >&2
exit 2
