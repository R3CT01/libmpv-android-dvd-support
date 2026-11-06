#!/bin/sh
# Make and manage PEK Cloud invite codes. Needs curl.
#   export PEK_CLOUD_URL="https://your-worker.your-name.workers.dev"
#   export PEK_ADMIN_KEY="the ADMIN_KEY secret you set on the worker"
#   sh invite.sh new [count] [note]      make codes (shown once)
#   sh invite.sh list                    see every code's status
#   sh invite.sh revoke <id>             cancel an unused code
[ -n "$PEK_CLOUD_URL" ] && [ -n "$PEK_ADMIN_KEY" ] || { echo "Set PEK_CLOUD_URL and PEK_ADMIN_KEY first."; exit 1; }
call() { curl -s -X POST "$PEK_CLOUD_URL/v1/invites/$1" -H "Authorization: Bearer $PEK_ADMIN_KEY" -H "Content-Type: application/json" -d "$2"; echo; }
case "$1" in
  new)    n="${2:-1}"; note="$3"; case "$n" in ''|*[!0-9]*) echo "count must be a number"; exit 1;; esac
          note=$(printf '%s' "$note" | tr -d '"\\'); call new "{\"count\":$n,\"note\":\"$note\"}" ;;
  list)   call list '{}' ;;
  revoke) [ -n "$2" ] || { echo "usage: invite.sh revoke <id>"; exit 1; }; call revoke "{\"id\":\"$2\"}" ;;
  *)      echo "usage: invite.sh new [count] [note] | list | revoke <id>"; exit 1 ;;
esac
