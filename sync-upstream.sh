#!/usr/bin/env bash
# Re-copy the skills listed in upstream.txt from their source repos, so they
# stay current. Each copied folder gets the upstream LICENSE and an
# UPSTREAM.md saying where it came from. If a skill's files didn't change,
# UPSTREAM.md keeps the commit it already records, so there's no diff.
# Local edits to those folders are overwritten, so change them upstream
# instead.
#
# Usage: ./sync-upstream.sh            sync every skill in upstream.txt
#        ./sync-upstream.sh <folder>   sync just that one
#
# Review the result with `git diff`, then commit on a branch and open a PR.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$REPO_DIR/upstream.txt"
only="${1:-}"

for tool in git curl; do
  command -v "$tool" >/dev/null || { echo "✗ $tool is required but not installed"; exit 1; }
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

synced=0
while read -r folder url path license_url; do
  case "$folder" in ''|'#'*) continue ;; esac
  [ -z "$only" ] || [ "$only" = "$folder" ] || continue

  # Clone each source repo once, shallow.
  clone="$tmp/$(echo "$url" | tr -c 'A-Za-z0-9' '_')"
  if [ ! -d "$clone" ]; then
    echo "→ fetching $url"
    git clone -q --depth 1 "$url" "$clone"
  fi
  src="$clone/$path"
  [ -f "$src/SKILL.md" ] || { echo "✗ $folder: no SKILL.md at $path in $url"; exit 1; }
  commit="$(git -C "$clone" rev-parse HEAD)"

  dest="$REPO_DIR/$folder"
  # Keep the previous copy to tell whether anything really changed.
  old="$tmp/old-$folder"
  rm -rf "$old"
  [ ! -d "$dest" ] || mv "$dest" "$old"
  mkdir -p "$dest"
  cp -R "$src"/. "$dest"/

  if [ ! -f "$dest/LICENSE" ] && [ ! -f "$dest/LICENSE.txt" ]; then
    if [ -n "${license_url:-}" ]; then
      curl -fsSL "$license_url" -o "$dest/LICENSE"
    else
      echo "! $folder: no LICENSE found upstream; add a <license-url> in upstream.txt"
    fi
  fi

  # Upstream repos get commits that don't touch this skill. If nothing but
  # UPSTREAM.md would change, keep the commit it already records so the
  # sync doesn't produce a diff (and a pull request) for nothing.
  status="✓"
  if [ -f "$old/UPSTREAM.md" ] && diff -rq -x UPSTREAM.md "$old" "$dest" >/dev/null; then
    old_commit="$(sed -n 's/^at commit `\([0-9a-f]\{40\}\)`.*/\1/p' "$old/UPSTREAM.md")"
    [ -z "$old_commit" ] || { commit="$old_commit"; status="="; }
  fi

  license_file=LICENSE
  [ -f "$dest/LICENSE" ] || [ ! -f "$dest/LICENSE.txt" ] || license_file=LICENSE.txt

  cat > "$dest/UPSTREAM.md" <<EOF
# Upstream source

This skill is copied from [$url]($url/tree/$commit/$path)
at commit \`$commit\`. See \`$license_file\` for its terms.

Don't edit it here: \`sync-upstream.sh\` overwrites this folder. Send changes
upstream instead.
EOF
  if [ "$status" = "=" ]; then
    echo "= $folder unchanged (still $path @ ${commit:0:7})"
  else
    echo "✓ $folder ← $url ($path @ ${commit:0:7})"
  fi
  synced=$((synced+1))
done < "$MANIFEST"

[ "$synced" -gt 0 ] || { echo "✗ nothing synced${only:+ (no '$only' in upstream.txt)}"; exit 1; }
echo "✓ synced $synced skill(s). Review with: git diff --stat"
