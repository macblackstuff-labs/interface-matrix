#!/usr/bin/env bash
# Install this repo's skill with the Vercel `skills` CLI into a throwaway HOME, once per
# agent named on the command line, and run the skill's own self-check from each installed
# copy. Usage: .github/scripts/smoke-install.sh claude-code codex cursor gemini-cli ...
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
[ $# -gt 0 ] || { echo "usage: $0 <agent> [agent...]" >&2; exit 2; }

# Each agent gets its own throwaway home: all agents except claude-code install into the
# shared ~/.agents/skills/, so a single home would make the one-installed-copy assert below
# pass for the first agent and then see the previous agent's copy for the rest.
for agent in "$@"; do
  home=$(mktemp -d)
  echo "== skills add --list ($agent)"
  HOME="$home" npx --yes skills add "$repo" --list
  echo "== skills add -a $agent"
  HOME="$home" npx --yes skills add "$repo" --skill interface-matrix -g -a "$agent" -y --copy

  found=$(find "$home" -path "*/interface-matrix/SKILL.md" -print)
  count=$(printf '%s' "$found" | grep -c . || true)
  [ "$count" = 1 ] || { echo "expected 1 installed skill for $agent, found $count" >&2; exit 1; }
  dir=$(dirname "$found")
  echo "== $agent: installed at ${dir#"$home"/}"
  for f in SKILL.md scripts/interface_matrix.py scripts/test_interface_matrix.py references/RUNBOOK.md; do
    [ -f "$dir/$f" ] || { echo "missing $f in installed skill for $agent" >&2; exit 1; }
  done
  ( cd "$dir" && python3 scripts/test_interface_matrix.py && python3 -O scripts/test_interface_matrix.py )
  rm -rf "$home"
done
