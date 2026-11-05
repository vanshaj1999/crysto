#!/usr/bin/env bash
# Usage: new-project.sh <name>
# Creates $CRYSTO_ROOT/<name> with git, CLAUDE.md, STATUS.md, private/, seeded memory and a
# PROJECTS.md row in the hub.
set -euo pipefail

hub="$(cd "$(dirname "$0")/.." && pwd)"
root="${CRYSTO_ROOT:-$(dirname "$hub")}"
config_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
projects="${CRYSTO_PROJECTS:-$hub/PROJECTS.md}"
name="${1:-}"

fail() { echo "$1" >&2; exit 1; }
[[ -n "$name" ]] || fail "usage: new-project.sh <name>"
[[ "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]] || fail "name must be lowercase letters, digits and dashes"
[[ -d "$root" ]] || fail "CRYSTO_ROOT $root does not exist"
root="$(cd "$root" && pwd)"
dir="$root/$name"
[[ -e "$dir" ]] && fail "$dir already exists"

today="$(date '+%-d %b %Y')"
sed_escape() { printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'; }
render() {
  sed -e "s|{{NAME}}|$(sed_escape "$name")|g" \
      -e "s|{{HUB}}|$(sed_escape "$hub")|g" \
      -e "s|{{DATE}}|$(sed_escape "$today")|g" "$1"
}

mkdir -p "$dir/private"
render "$hub/templates/CLAUDE.md" > "$dir/CLAUDE.md"
render "$hub/templates/STATUS.md" > "$dir/STATUS.md"
printf 'private/\n.env\n.DS_Store\n' > "$dir/.gitignore"
git -C "$dir" init -q -b main
git -C "$dir" add -A
git -C "$dir" commit -q -m "Start $name project"

# Claude Code keys project memory by the directory path with every non-alphanumeric turned into -.
mem="$config_dir/projects/$(printf '%s' "$dir" | sed 's/[^A-Za-z0-9]/-/g')/memory"
mkdir -p "$mem"
for f in "$hub/templates/memory-seed/"*.md; do
  [[ -e "$f" ]] || continue
  b="$(basename "$f")"
  cp "$f" "$mem/$b"
  desc="$(sed -n 's/^description: *//p' "$f" | head -1)"
  echo "- [${b%.md}]($b) -- $desc" >> "$mem/MEMORY.md"
done

[[ -f "$projects" ]] || cp "$hub/templates/PROJECTS.md" "$projects"
# shellcheck disable=SC2016  # the backticks are literal markdown
printf '| %s | `%s` | Started %s |\n' "$name" "${dir#"$root"/}" "$today" >> "$projects"

echo "Created $name"
echo "  folder  $dir"
echo "  memory  $mem"
