#!/usr/bin/env bash
# Tests for block-env-access.sh. Exit code 2 means blocked, 0 means allowed.
hook="$(dirname "$0")/block-env-access.sh"
fail=0
check() {
  local want=$1 cmd=$2
  jq -n --arg c "$cmd" '{tool_name:"Bash",tool_input:{command:$c}}' | bash "$hook" 2>/dev/null
  local got=$?
  if [ "$got" != "$want" ]; then echo "FAIL want=$want got=$got: $cmd"; fail=1; fi
}
check 2 'cat .env'
check 2 'cat ./.env'
check 2 'source .env.local'
check 2 'grep KEY .env.production'
check 2 'cat ~/proj/.env'
check 2 'ls; cat .env*'
check 2 'cp .env /tmp/x'
check 2 'head -1 ".env"'
check 2 'echo x && cat .env.*'
check 2 "awk 1 '.env'"
check 0 'cat .env.example'
check 0 'cat .env.sample'
check 0 'cat .env.tpl'
check 0 'cat .envrc'
check 0 'node -e "console.log(process.env.HOME)"'
check 0 'grep -r import.meta.env src'
check 0 'ls -la'
check 0 'git status'
[ $fail = 0 ] && echo "ALL PASS"
exit $fail
