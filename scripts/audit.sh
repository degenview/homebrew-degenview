#!/usr/bin/env bash
# Runs `brew style` and `brew audit` on every cask, with the tap checked out at $TAP_DIR (default
# the repository root) and linked into Homebrew's Taps folder.
#
# `brew audit` always reports "is a GitHub pre-release" for a release candidate. That is the point of
# `degenview@rc`, so that one line is accepted; any other problem fails.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tap_dir="$(brew --repository)/Library/Taps/degenview"
mkdir -p "$tap_dir"
[ -e "$tap_dir/homebrew-degenview" ] || ln -s "$root" "$tap_dir/homebrew-degenview"
brew trust degenview/degenview

shopt -s nullglob
casks=("$root"/Casks/*.rb)
[ "${#casks[@]}" -gt 0 ] || { echo "No casks."; exit 1; }

failed=0
for file in "${casks[@]}"; do
  token="$(basename "$file" .rb)"
  ref="degenview/degenview/$token"
  echo "== $ref"
  brew style --cask "$ref" || failed=1
  # --online reaches GitHub for the URL and the release; the download itself is `brew fetch`.
  out="$(brew audit --cask --strict --online "$ref" 2>&1 || true)"
  echo "$out"
  problems="$(printf '%s\n' "$out" | grep -E '^ - ' | grep -v -F 'is a GitHub pre-release' || true)"
  if [ -n "$problems" ]; then
    failed=1
  fi
  # Downloads the zip for this CPU and checks the sha256 in the cask.
  brew fetch --cask "$ref" || failed=1
done
exit "$failed"
