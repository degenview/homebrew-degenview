#!/usr/bin/env bash
# Rewrites Casks/ from the app's GitHub releases. Runs in the `bump` workflow, which has no secrets
# beyond its own read-only-for-releases token, and by hand.
#
#   SOURCE_REPO   owner/name of the app repository (degenview/degenview)
#   GH_TOKEN      a token that can read public releases (the workflow's own, or `gh auth login`)
#   OUT           scratch directory for downloads (default out)
#
# Two casks come out of it:
#   degenview      the newest final release            (Casks/degenview.rb; absent until one exists)
#   degenview@rc   the newest final or `-rc.N` release (Casks/degenview@rc.rb)
# `degenview@rc` is the cask for the app's Release Candidate update channel, which also accepts
# finals, so when a final is the newest release both casks name it.
#
# A cask pins the sha256 of the zip, so every zip is downloaded and checked here: the release must
# be immutable (`gh release verify`), the file must be the one the release recorded
# (`verify-asset`), and its build provenance must name the app's release workflow. The hash written
# is of the downloaded bytes, never read back from the API.
set -euo pipefail

: "${SOURCE_REPO:?}"
OUT="${OUT:-out}"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$here/.."
mkdir -p "$OUT/zips"

gh api "repos/${SOURCE_REPO}/releases?per_page=50" > "$OUT/releases.json"

# Releases the app's own release workflow made, newest first by version, never by upload time (a
# patch release of an old line must not outrank a candidate of a newer line; a final is newer than
# its own candidates). A draft, a release somebody made by hand and any tag that is not a final or
# an `-rc.N` (the app's updater offers no alpha or beta to any channel) are ignored.
jq '
  def version_key:
    capture("^v(?<a>[0-9]+)\\.(?<b>[0-9]+)\\.(?<c>[0-9]+)(-rc\\.(?<n>[0-9]+))?$")
    | [(.a | tonumber), (.b | tonumber), (.c | tonumber),
       (if .n then 0 else 1 end),
       ((.n // "0") | tonumber)];

  [ .[]
    | select(.draft | not)
    | select(.author.login == "github-actions[bot]")
    | select(.tag_name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+(-rc\\.[0-9]+)?$"))
    | {tag: .tag_name, prerelease: .prerelease, assets: [.assets[].name]}
    | select(
        . as $r
        | ($r.assets | index("DegenView-" + $r.tag + "-macos-arm64.zip")) != null
          and ($r.assets | index("DegenView-" + $r.tag + "-macos-x64.zip")) != null)
    | {tag, prerelease}
  ] | sort_by(.tag | version_key) | reverse
  | {stable: (map(select(.prerelease | not)) | first | .tag),
     rc: (first | .tag)}
' "$OUT/releases.json" > "$OUT/selected.json"

stable="$(jq -r '.stable // empty' "$OUT/selected.json")"
rc="$(jq -r '.rc // empty' "$OUT/selected.json")"

if [ -z "$rc" ]; then
  echo "No release with both macOS zips yet; nothing to write."
  exit 0
fi

# Downloads and verifies both zips of a tag, then prints "<arm64 sha256> <x64 sha256>".
shas() {
  local tag="$1" cpu name sum out=()
  gh release verify "$tag" --repo "$SOURCE_REPO" >&2
  for cpu in arm64 x64; do
    name="DegenView-${tag}-macos-${cpu}.zip"
    gh release download "$tag" --repo "$SOURCE_REPO" --pattern "$name" --dir "$OUT/zips" --clobber >&2
    gh release verify-asset "$tag" "$OUT/zips/$name" --repo "$SOURCE_REPO" >&2
    gh attestation verify "$OUT/zips/$name" --repo "$SOURCE_REPO" \
      --signer-workflow "${SOURCE_REPO}/.github/workflows/release.yml" >&2
    sum="$(shasum -a 256 "$OUT/zips/$name" | cut -d' ' -f1)"
    out+=("$sum")
  done
  echo "${out[*]}"
}

# write_cask <file> <token> <tag> <arm64 sha> <x64 sha> <conflicts-with token> <livecheck>
write_cask() {
  local file="$1" token="$2" tag="$3" arm="$4" intel="$5" other="$6" livecheck="$7"
  cat > "$file" <<EOF
# Written by scripts/bump.sh from the ${SOURCE_REPO} release ${tag}. Do not edit by hand.
cask "${token}" do
  arch arm: "arm64", intel: "x64"

  version "${tag#v}"
  sha256 arm:   "${arm}",
         intel: "${intel}"

  url "https://github.com/${SOURCE_REPO}/releases/download/v#{version}/DegenView-v#{version}-macos-#{arch}.zip"
  name "DegenView"
  desc "Market dashboard with charts, Pine scripts and alerts"
  homepage "https://degenview.app/"

${livecheck}

  auto_updates true
  conflicts_with cask: "${other}"
  depends_on macos: :sonoma

  app "DegenView.app"

  uninstall quit: "es.nico.degenview"

  zap trash: [
    "~/Library/Application Support/es.nico.degenview",
    "~/Library/Caches/es.nico.degenview",
    "~/Library/Preferences/es.nico.degenview.plist",
    "~/Library/Saved Application State/es.nico.degenview.savedState",
  ]
end
EOF
}

stable_livecheck='  livecheck do
    url :url
    strategy :github_latest
  end'
# `:github_releases` skips prereleases, and this cask follows them, so there is nothing to ask.
rc_livecheck='  livecheck do
    skip "Written by the bump workflow of the tap from the newest final or release candidate."
  end'

mkdir -p "$root/Casks"

if [ -n "$stable" ]; then
  read -r arm intel < <(shas "$stable")
  write_cask "$root/Casks/degenview.rb" degenview "$stable" "$arm" "$intel" "degenview@rc" "$stable_livecheck"
  echo "degenview      -> $stable"
fi

if [ "$rc" = "$stable" ]; then
  write_cask "$root/Casks/degenview@rc.rb" "degenview@rc" "$rc" "$arm" "$intel" "degenview" "$rc_livecheck"
else
  read -r arm intel < <(shas "$rc")
  write_cask "$root/Casks/degenview@rc.rb" "degenview@rc" "$rc" "$arm" "$intel" "degenview" "$rc_livecheck"
fi
echo "degenview@rc   -> $rc"
