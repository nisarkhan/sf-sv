#!/usr/bin/env bash
# Shows which version of the skill and template Claude Code is actually running.
REPO="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN="$REPO/plugins/sf-solution-verifier"
CACHE="$HOME/.claude/plugins/cache/sf-sv/sf-solution-verifier"

echo "Repo:  $REPO"
printf "  plugin.json version : "; grep -o '"version"[^,]*' "$PLUGIN/.claude-plugin/plugin.json" | head -1
printf "  SKILL.md version    : "; grep -m1 "SKILL VERSION" "$PLUGIN/skills/sf-solution-verifier/SKILL.md" || echo "not marked"
printf "  template version    : "; grep -m1 "TEMPLATE VERSION" "$PLUGIN/assets/report-template.html" || echo "not marked"

echo
if [ ! -d "$CACHE" ]; then
  echo "Cache: none found. The plugin is not installed on this machine."
  exit 0
fi
echo "Cache: $CACHE"
for V in "$CACHE"/*/; do
  V="${V%/}"; N="$(basename "$V")"
  echo "  version folder      : $N"
  S="$(find "$V" -name SKILL.md | head -1)"
  T="$(find "$V" -name report-template.html | head -1)"
  [ -n "$S" ] && { printf "    SKILL.md version  : "; grep -m1 "SKILL VERSION" "$S" || echo "not marked"; }
  [ -n "$T" ] && { printf "    template version  : "; grep -m1 "TEMPLATE VERSION" "$T" || echo "not marked"; }
  echo "    matches repo?"
  [ -n "$S" ] && { diff -q "$PLUGIN/skills/sf-solution-verifier/SKILL.md" "$S" >/dev/null 2>&1 \
      && echo "      SKILL.md          : same as repo" || echo "      SKILL.md          : DIFFERENT, run /plugin marketplace update sf-sv"; }
  [ -n "$T" ] && { diff -q "$PLUGIN/assets/report-template.html" "$T" >/dev/null 2>&1 \
      && echo "      template          : same as repo" || echo "      template          : DIFFERENT, run /plugin marketplace update sf-sv"; }
done
