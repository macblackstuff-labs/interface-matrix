#!/usr/bin/env bash
# Install this repo's skill with the Vercel `skills` CLI into a throwaway HOME, once per
# agent, and run the skill's own self-check from each installed copy. With no arguments,
# the agent list is read from the CLI itself, so agents it gains are covered automatically.
# Usage: .github/scripts/smoke-install.sh [agent...]
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)

# Agents the CLI lists but cannot install globally: "<agent>|<one-line reason>" each. They
# are reported at the end and excluded from the pass count rather than silently skipped.
exceptions=(
  "eve|the CLI reports Eve does not support global skill installation"
  "promptscript|the CLI reports PromptScript does not support global skill installation"
)

strip_ansi() { sed -E $'s/\033\\[[0-9;?]*[a-zA-Z]//g'; }

reason_for() {
  local e
  for e in ${exceptions[@]+"${exceptions[@]}"}; do
    [ "${e%%|*}" = "$1" ] && { echo "${e#*|}"; return; }
  done
  return 0
}

# Ask the CLI for its own agent list: an invalid -a makes it print "Valid agents: a, b, ...".
# Output is joined into one line first, so a wrapped list is parsed the same as an unwrapped one.
list_agents() {
  local home out
  home=$(mktemp -d)
  out=$(HOME="$home" npx --yes skills add "$repo" --skill interface-matrix -g \
    -a __invalid__ -y --copy 2>&1 | strip_ansi | tr '\n' ' ' || true)
  rm -rf "$home"
  printf '%s' "${out##*Valid agents:}" \
    | grep -oE '[A-Za-z0-9._-]+(, *[A-Za-z0-9._-]+)+' \
    | head -1 | tr ',' '\n' | sed -E 's/^ +//; s/ +$//'
}

agents=()
if [ $# -gt 0 ]; then
  agents=("$@")
else
  while IFS= read -r a; do [ -n "$a" ] && agents+=("$a"); done < <(list_agents)
  [ "${#agents[@]}" -gt 0 ] || { echo "could not parse the skills CLI agent list" >&2; exit 1; }
fi

echo "== skills add --list"
home=$(mktemp -d); HOME="$home" npx --yes skills add "$repo" --list; rm -rf "$home"

total=${#agents[@]}
passed=0
skipped=()

# Each agent gets its own throwaway home: most agents install into the shared
# ~/.agents/skills/, so a single home would make the one-installed-copy assert below pass
# for the first agent and then see the previous agent's copy for the rest.
for agent in "${agents[@]}"; do
  reason=$(reason_for "$agent")
  if [ -n "$reason" ]; then
    echo "== $agent: SKIPPED — $reason"
    skipped+=("$agent: $reason")
    continue
  fi
  home=$(mktemp -d)
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
  passed=$((passed + 1))
done

for s in ${skipped[@]+"${skipped[@]}"}; do echo "exception: $s"; done
echo "$passed of $total agents installed and tested"
