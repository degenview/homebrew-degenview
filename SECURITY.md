# Security policy

Report a problem with this repository, or with a cask in it, privately through
[GitHub's private vulnerability reporting](https://github.com/degenview/homebrew-degenview/security/advisories/new)
(Security tab, "Report a vulnerability"). Do not open a public issue for it. For the app itself, use
the [policy of degenview/degenview](https://github.com/degenview/degenview/security/policy).

## What protects what you install

- Every cask names a zip from an immutable release made by the app's own release workflow, and pins
  its sha256. `scripts/bump.sh` checks the release and the file (`gh release verify`,
  `gh release verify-asset`, `gh attestation verify --signer-workflow
  degenview/degenview/.github/workflows/release.yml`) before it writes the hash, and Homebrew checks
  the hash again on every install.
- The app is signed with a Developer ID, notarized and stapled.
- The job that downloads and verifies files has a read-only token; a separate job writes the pull
  request. A person merges it.

## What does not

- Anyone who can merge to `main` here can point a cask at a different file. That is limited to the
  maintainer, with required checks.
- The hash proves the file is the one the release held when the cask was written, not that the
  release is good; that rests on the app repository's signed tags.
