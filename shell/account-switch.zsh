# Pick the Claude Code and GitHub CLI accounts from the current directory.
# Source this from ~/.zshrc. Announces only on a change, because a silent switch is how you spend
# one plan's limits while you think you are on the other.

# Edit these paths.
CRYSTO_PERSONAL_ROOT="${CRYSTO_PERSONAL_ROOT:-$HOME/personal}"
CLAUDE_PERSONAL_DIR="${CLAUDE_PERSONAL_DIR:-$HOME/.claude-personal}"
GH_PERSONAL_DIR="${GH_PERSONAL_DIR:-$HOME/.config/gh-personal}"

# Run the personal account explicitly from anywhere.
claude-personal() { CLAUDE_CONFIG_DIR="$CLAUDE_PERSONAL_DIR" claude "$@"; }

_crysto_is_personal_dir() {
  [[ "$PWD/" == "$CRYSTO_PERSONAL_ROOT/"* ]]
}

_crysto_claude_account() {
  local want=""
  _crysto_is_personal_dir && want="$CLAUDE_PERSONAL_DIR"
  [[ "$want" == "${CLAUDE_CONFIG_DIR:-}" ]] && return
  if [[ -n "$want" ]]; then
    export CLAUDE_CONFIG_DIR="$want"
    print -P "%F{yellow}claude -> personal%f"
  else
    unset CLAUDE_CONFIG_DIR
    print -P "%F{cyan}claude -> default%f"
  fi
}

_crysto_gh_account() {
  if _crysto_is_personal_dir; then
    export GH_CONFIG_DIR="$GH_PERSONAL_DIR"
  else
    unset GH_CONFIG_DIR
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _crysto_claude_account
add-zsh-hook chpwd _crysto_gh_account
_crysto_claude_account
_crysto_gh_account
