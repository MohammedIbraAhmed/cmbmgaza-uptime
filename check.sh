#!/usr/bin/env bash
# Checks the CMBM Gaza services from outside their server. One line per check (✓/✗);
# exits 1 when anything failed. Each check is tried twice, 20 s apart, so one network
# blip is not reported as an outage. TEST_ALERT=1 adds a fake failure (to test the emails).
set -u
failed=0

http() { # url [text the reply must contain]
  local body
  body=$(curl -fsS -m 20 -A 'cmbmgaza-uptime (+https://github.com/MohammedIbraAhmed/cmbmgaza-uptime)' "$1" 2>/dev/null) || return 1
  [[ -z "${2:-}" || "$body" == *"$2"* ]]
}

smtp() { # host:port with TLS from the start (465); the server must greet with 220
  { sleep 5; } | timeout 20 openssl s_client -quiet -connect "$1" -servername "${1%%:*}" 2>/dev/null | head -1 | grep -q '^220'
}

cert() { # host [port]: the security certificate must be valid for 14 more days
  local end
  end=$(echo | timeout 20 openssl s_client -connect "$1:${2:-443}" -servername "$1" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
  [[ -n "$end" ]] || return 1
  (( ($(date -d "$end" +%s) - $(date +%s)) / 86400 >= 14 ))
}

check() { # "what it is" command...
  local name=$1; shift
  if "$@" || { sleep 20; "$@"; }; then echo "✓ $name"; else echo "✗ $name"; failed=1; fi
}

check 'Website opens (cmbmgaza.org)' http https://cmbmgaza.org/
check 'Website database' http 'https://cmbmgaza.org/healthz?deep=1' '"db":"ok"'
check 'Activities app (app.cmbmgaza.org)' http https://app.cmbmgaza.org/api/health '"status":"ok"'
check 'Activities list the website shows' http https://app.cmbmgaza.org/api/public/activities '"activities"'
check 'Mail server (mx.cmbmgaza.org)' smtp mx.cmbmgaza.org:465
check 'Certificate of cmbmgaza.org (14+ days left)' cert cmbmgaza.org
check 'Certificate of app.cmbmgaza.org (14+ days left)' cert app.cmbmgaza.org
check 'Certificate of mx.cmbmgaza.org (14+ days left)' cert mx.cmbmgaza.org 465
if [[ "${TEST_ALERT:-}" == 1 ]]; then echo '✗ Test alert (not a real problem)'; failed=1; fi

exit $failed
