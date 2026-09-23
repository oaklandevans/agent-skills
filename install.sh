#!/usr/bin/env bash
# Link every skill in this repo into the personal skill folders of each agent.
#
#   Copilot and opencode read ~/.agents/skills. If this repo is cloned there,
#   they need nothing else. Claude Code only reads ~/.claude/skills, so each
#   skill gets a symlink there.
#
# Usage: ./install.sh            link skills (safe to re-run)
#        ./install.sh --check    only validate SKILL.md files
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$HOME/.agents/skills"
CLAUDE_DIR="$HOME/.claude/skills"

errors=0
skills=()

# Validate each skill against the Agent Skills spec (the strictest rules
# among the supported agents are opencode's).
for skill_md in "$REPO_DIR"/*/SKILL.md; do
  [ -e "$skill_md" ] || continue
  dir="$(dirname "$skill_md")"
  folder="$(basename "$dir")"
  name="$(sed -n '/^---$/,/^---$/{s/^name:[[:space:]]*//p;}' "$skill_md" | head -1 | tr -d '"'"'"'')"
  desc="$(sed -n '/^---$/,/^---$/{s/^description:[[:space:]]*//p;}' "$skill_md" | head -1)"

  if [ "$(head -1 "$skill_md")" != "---" ]; then
    echo "✗ $folder: SKILL.md must start with YAML frontmatter (---)"; errors=$((errors+1)); continue
  fi
  if [ "$name" != "$folder" ]; then
    echo "✗ $folder: frontmatter name '$name' must match folder name"; errors=$((errors+1))
  fi
  if ! [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || [ ${#name} -gt 64 ]; then
    echo "✗ $folder: name must be lowercase letters/digits with single hyphens, max 64 chars"; errors=$((errors+1))
  fi
  if [ -z "$desc" ] || [ ${#desc} -gt 1024 ]; then
    echo "✗ $folder: description is required (max 1024 chars)"; errors=$((errors+1))
  fi
  skills+=("$folder")
done

if [ "$errors" -gt 0 ]; then
  echo "$errors problem(s) found. Fix them before installing."; exit 1
fi
echo "✓ ${#skills[@]} skill(s) valid: ${skills[*]:-none}"

# This repo is public: scan everything for private info, and make sure the
# pre-commit hook that does the same on every commit is turned on.
if [ -d "$REPO_DIR/.git" ]; then
  "$REPO_DIR/.githooks/pre-commit" --all || exit 1
  git -C "$REPO_DIR" config core.hooksPath .githooks
fi
[ "${1:-}" = "--check" ] && exit 0

# Copilot + opencode: point ~/.agents/skills at this repo if it isn't already.
if [ "$REPO_DIR" != "$AGENTS_DIR" ]; then
  if [ -e "$AGENTS_DIR" ] && [ ! -L "$AGENTS_DIR" ]; then
    echo "! $AGENTS_DIR exists and is not this repo; leaving it alone."
    echo "  Copilot/opencode won't see these skills until you clone the repo there."
  else
    mkdir -p "$(dirname "$AGENTS_DIR")"
    ln -sfn "$REPO_DIR" "$AGENTS_DIR"
    echo "→ linked $AGENTS_DIR → $REPO_DIR"
  fi
fi

# Claude Code: one symlink per skill (Claude keeps its own synced/ folder here).
mkdir -p "$CLAUDE_DIR"
for folder in "${skills[@]}"; do
  target="$CLAUDE_DIR/$folder"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "! $target is a real folder, not a link; skipping."
    continue
  fi
  ln -sfn "$REPO_DIR/$folder" "$target"
done

# Remove Claude links to skills that were deleted from this repo.
for link in "$CLAUDE_DIR"/*; do
  [ -L "$link" ] || continue
  case "$(readlink "$link")" in
    "$REPO_DIR"/*) [ -e "$link" ] || { rm "$link"; echo "→ removed stale link $(basename "$link")"; } ;;
  esac
done

echo "✓ Claude Code: linked ${#skills[@]} skill(s) into $CLAUDE_DIR"
echo "✓ Copilot and opencode: reading from $AGENTS_DIR"
