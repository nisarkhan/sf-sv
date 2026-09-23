#!/usr/bin/env bash
# sf-solution-verifier installer
# Usage:
#   ./install.sh                      interactive, paste your own Context7 key
#   ./install.sh --oauth              sign in to Context7 in the browser, no key to paste
#   ./install.sh --proxy https://...  use the team gateway, no key needed at all
set -euo pipefail

MODE="interactive"; PROXY_URL=""
while [ $# -gt 0 ]; do
  case "$1" in
    --oauth) MODE="oauth"; shift ;;
    --proxy) MODE="proxy"; PROXY_URL="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

SHELL_RC="$HOME/.zshrc"; [ -n "${BASH_VERSION:-}" ] && [ -f "$HOME/.bashrc" ] && SHELL_RC="$HOME/.bashrc"
say()  { printf "\n\033[1m%s\033[0m\n" "$1"; }
load_node() {
  command -v npx >/dev/null 2>&1 && return 0
  for f in "$HOME/.nvm/nvm.sh" "/opt/homebrew/opt/nvm/nvm.sh" "/usr/local/opt/nvm/nvm.sh"; do
    [ -s "$f" ] && . "$f" >/dev/null 2>&1 && break
  done
  command -v fnm >/dev/null 2>&1 && eval "$(fnm env 2>/dev/null)" >/dev/null 2>&1
  for d in /opt/homebrew/bin /usr/local/bin; do
    [ -x "$d/npx" ] && PATH="$d:$PATH" && export PATH
  done
  command -v npx >/dev/null 2>&1
}
ok()   { printf "  ok    %s\n" "$1"; }
warn() { printf "  note  %s\n" "$1"; }
fail() { printf "  stop  %s\n" "$1"; exit 1; }

say "1. Checking tools"
command -v claude >/dev/null || fail "Claude Code not found. Install it, then run this again."
ok "Claude Code $(claude --version 2>/dev/null | head -1)"
if load_node; then ok "Node $(node -v 2>/dev/null || echo present)"; else warn "Node not found. Not needed for the key route, only for --oauth."; fi

say "2. Setting up Context7 access"
add_to_rc() { # name value
  if grep -q "^export $1=" "$SHELL_RC" 2>/dev/null; then
    warn "$1 already in $(basename "$SHELL_RC"), leaving it as is"
  else
    printf '\nexport %s="%s"\n' "$1" "$2" >> "$SHELL_RC"
    ok "added $1 to $(basename "$SHELL_RC")"
  fi
  export "$1"="$2"
}

case "$MODE" in
  proxy)
    [ -n "$PROXY_URL" ] || fail "--proxy needs a URL"
    add_to_rc CONTEXT7_MCP_URL "$PROXY_URL"
    ok "using the team gateway, no personal key needed"
    ;;
  oauth)
    if load_node; then
      npx -y ctx7 setup
      ok "signed in to Context7, key stored by the CLI"
    else
      warn "npx not found, so browser sign-in is unavailable on this machine."
      printf "  Node may be installed but not on this shell's PATH. Check with:\n"
      printf "    node -v ; which npx\n"
      printf "  To install Node:  brew install node\n\n"
      printf "  You can continue now with an API key instead, which needs no Node.\n"
      printf "  Paste your Context7 API key, or press Enter to stop and install Node: "
      read -rs KEY; printf "\n"
      [ -n "$KEY" ] || fail "stopped. Install Node, then run: ./scripts/install.sh --oauth"
      add_to_rc CONTEXT7_API_KEY "$KEY"
    fi
    ;;
  *)
    if [ -n "${CONTEXT7_API_KEY:-}" ]; then
      ok "CONTEXT7_API_KEY already set in this shell"
    else
      printf "  Paste your Context7 API key (starts with ctx7sk), input is hidden: "
      read -rs KEY; printf "\n"
      [ -n "$KEY" ] || fail "no key entered"
      case "$KEY" in ctx7sk*) : ;; *) warn "that does not look like a Context7 key, continuing anyway" ;; esac
      add_to_rc CONTEXT7_API_KEY "$KEY"
    fi
    ;;
esac

say "3. Testing the connection"
if [ "$MODE" = "proxy" ]; then
  CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 20 "$PROXY_URL" || true)
  case "$CODE" in 2*|3*|4*) ok "gateway reachable (HTTP $CODE)" ;; *) warn "gateway did not answer, check the URL with whoever runs it" ;; esac
else
  CODE=$(curl -s -o /tmp/c7test.txt -w "%{http_code}" --max-time 30 -G "https://context7.com/api/v2/context" \
    --data-urlencode "libraryId=/llmstxt/developer_salesforce_llms_txt" \
    --data-urlencode "query=ConnectApi CdpQuery Apex" \
    -H "Authorization: Bearer ${CONTEXT7_API_KEY:-}" || true)
  case "$CODE" in
    200) ok "Context7 answered with Salesforce docs" ;;
    401|403) fail "Context7 rejected the key. Create a new one at context7.com/dashboard and run this again." ;;
    429) warn "rate limited right now, the key is valid" ;;
    *)   warn "unexpected response (HTTP $CODE), continuing" ;;
  esac
fi

say "4. Allowing fetches from Salesforce sites only"
python3 - << 'PY'
import json, os, shutil
p = os.path.expanduser("~/.claude/settings.json")
os.makedirs(os.path.dirname(p), exist_ok=True)
data = {}
if os.path.exists(p):
    shutil.copy(p, p + ".backup")
    try: data = json.load(open(p))
    except Exception: print("  note  settings.json was not valid JSON, saved a copy as settings.json.backup"); data = {}
allow = data.setdefault("permissions", {}).setdefault("allow", [])
added = 0
for d in ["developer.salesforce.com","help.salesforce.com","architect.salesforce.com","www.salesforce.com"]:
    rule = f"WebFetch(domain:{d})"
    if rule not in allow: allow.append(rule); added += 1
json.dump(data, open(p,"w"), indent=2)
print(f"  ok    {added} domain rule(s) added, {len(allow)} total (nothing removed)")
PY

say "Done. Two commands left, inside Claude Code:"
cat << 'NEXT'
  /plugin marketplace add nisarkhan/sf-sv
  /plugin install sf-solution-verifier@sf-sv

Then restart Claude Code and test with:
  /sf-solution-verifier examples/test-solution.md

Open a new terminal window first so the settings above are loaded.
NEXT
