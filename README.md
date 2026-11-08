# DegenView Homebrew tap

Homebrew casks for [DegenView](https://github.com/degenview/degenview) on macOS (Apple Silicon and
Intel, macOS 14 or newer).

## Install

```bash
brew install --cask degenview/degenview/degenview      # the latest final release
brew install --cask degenview/degenview/degenview@rc   # the latest release candidate (or final, if newer)
```

Naming the cask in full is what lets this work in one command: Homebrew 7 taps the repository and
trusts that one cask as you install it. If you `brew tap degenview/degenview` first and then install
by short name (`brew install --cask degenview`), Homebrew refuses with "untrusted tap" until you run
`brew trust degenview/degenview`.

Both put `DegenView.app` in `/Applications`; install one at a time. The app is signed and notarized,
so there is nothing to approve in Gatekeeper.

DegenView updates itself from inside the app (Settings > About chooses the channel), so Homebrew
treats it as self-updating and `brew upgrade` skips it; `brew upgrade --greedy` does not. To remove it
together with its data, preferences and cache, `brew uninstall --zap --cask degenview`. Keychain items
(API keys) are not touched.

Until the first final release exists only `degenview@rc` is available.

## How the casks are made

Nothing is edited by hand. `.github/workflows/bump.yml` runs every six hours and pulls from the app's
GitHub releases; nothing in `degenview/degenview` holds a token for this repo.

| Job | Token | What it does |
| --- | --- | --- |
| `fetch` | read-only | `scripts/bump.sh` picks the releases (below), downloads both macOS zips and verifies them: `gh release verify` (immutable), `gh release verify-asset`, and `gh attestation verify --signer-workflow degenview/degenview/.github/workflows/release.yml`. The sha256 in the cask is that of the downloaded bytes. |
| `propose` | `contents`, `pull-requests`, `actions` write | Commits the changed casks to the `bump` branch, opens a pull request, and starts the **Check** workflow on the branch (a pull request opened with the workflow's own token starts none, and `main` requires it). |

A person merges the pull request. **Check** (`scripts/audit.sh`) runs `brew style`, `brew audit --strict
--online` and `brew fetch` (which verifies the hash) on every cask.

Releases are compared by version, never upload time:

- `degenview` is the newest final release. It does not exist before the first one.
- `degenview@rc` is the newest final or `-rc.N` release, the same set as the app's Release Candidate
  update channel. `-alpha.N` and `-beta.N` tags are in neither.

`brew audit` always reports "is a GitHub pre-release" for a release candidate. `scripts/audit.sh`
accepts that one line for `degenview@rc` and nothing else.

## One-time setup (maintainer)

1. Create the public repository `degenview/homebrew-degenview` (the name is what makes
   `brew install degenview/degenview/...` work) and push this one to it.
2. Settings > Actions > General: allow GitHub Actions to create pull requests.
3. Ruleset on `main`: require a pull request and the **Check** and **Workflow audit** checks; pin
   actions to a full commit hash.
4. Run **Bump** by hand once and merge the pull request.

## Limits

`zap` lists the folders the app is known to write (`~/Library/Application Support/es.nico.degenview`,
`Caches`, `Preferences`, `Saved Application State`). It cannot remove Keychain items or the
login-item registration, which macOS drops with the app.
