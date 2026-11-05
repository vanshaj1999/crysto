#!/usr/bin/env bash
# Runs new-project.sh in a throwaway root and checks what it creates.
# shellcheck disable=SC2016,SC2034
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/root"

export CRYSTO_ROOT="$tmp/root"
export CLAUDE_CONFIG_DIR="$tmp/claude"
export CRYSTO_PROJECTS="$tmp/PROJECTS.md"
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

pass=0
fail=0
check() {
  if eval "$2"; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: $1"; fi
}

"$repo/scripts/new-project.sh" tax >/dev/null
root="$(cd "$tmp/root" && pwd)"
dir="$root/tax"
mem="$tmp/claude/projects/$(printf '%s' "$dir" | sed 's/[^A-Za-z0-9]/-/g')/memory"

check "folder created" '[[ -d "$dir/private" ]]'
check "private is gitignored" 'grep -qx "private/" "$dir/.gitignore"'
check "CLAUDE.md has the name" 'grep -q "^# tax$" "$dir/CLAUDE.md"'
check "CLAUDE.md has the hub path" 'grep -q "$repo/COORDINATION.md" "$dir/CLAUDE.md"'
check "no placeholder left" '! grep -rq "{{" "$dir/CLAUDE.md" "$dir/STATUS.md"'
check "one commit" '[[ "$(git -C "$dir" rev-list --count HEAD)" == 1 ]]'
check "clean tree" '[[ -z "$(git -C "$dir" status --porcelain)" ]]'
check "memory seeded" '[[ -f "$mem/feedback-read-status-first.md" ]]'
check "memory index" 'grep -q "feedback-read-status-first" "$mem/MEMORY.md"'
check "projects row" 'grep -q "^| tax | \`tax\` |" "$CRYSTO_PROJECTS"'
check "projects header" 'grep -q "^| Project | Folder | What |" "$CRYSTO_PROJECTS"'

check "rejects an existing project" '! "$repo/scripts/new-project.sh" tax 2>/dev/null'
check "rejects capitals" '! "$repo/scripts/new-project.sh" Tax 2>/dev/null'
check "rejects a path" '! "$repo/scripts/new-project.sh" ../escape 2>/dev/null'
check "rejects no name" '! "$repo/scripts/new-project.sh" 2>/dev/null'
check "nothing escaped the root" '[[ ! -e "$tmp/escape" ]]'

"$repo/scripts/new-project.sh" passport >/dev/null
check "second project appends" '[[ "$(grep -c "^| [a-z]" "$CRYSTO_PROJECTS")" == 2 ]]'

echo "$pass passed, $fail failed"
[[ "$fail" == 0 ]]
