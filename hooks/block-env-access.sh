#!/usr/bin/env bash
# PreToolUse hook for Bash: block shell commands that touch .env files.
# Allows secret-free templates (.env.example, .env.sample, .env.template, .env.tpl, .env.dist) and .envrc.
cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

hits=$(printf '%s\n' "$cmd" \
  | grep -oE '(^|[^A-Za-z0-9_])\.env(\.[A-Za-z0-9_*.-]*|\*)?([^A-Za-z0-9_.*-]|$)' \
  | sed -E 's/^[^.]//; s/[^A-Za-z0-9_*.-]$//' \
  | grep -vE '\.(example|sample|template|tpl|dist)$')

if [ -n "$hits" ]; then
  echo "Blocked: command touches a .env file ($(echo "$hits" | head -1)). Secrets stay out of Claude's reach; use a template such as .env.example instead." >&2
  exit 2
fi
exit 0
