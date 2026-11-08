# Written by scripts/bump.sh from the degenview/degenview release v0.6.0-rc.17. Do not edit by hand.
cask "degenview@rc" do
  arch arm: "arm64", intel: "x64"

  version "0.6.0-rc.17"
  sha256 arm:   "8e47f0b8ed8dc118979bf5e14af8c38d0b69b69f4bbe99f228a6717160e358f4",
         intel: "df32636a75c0ab551c3e9dc61b2cb804bc64a5abce452eee655b7a390cad1f86"

  url "https://github.com/degenview/degenview/releases/download/v#{version}/DegenView-v#{version}-macos-#{arch}.zip"
  name "DegenView"
  desc "Market dashboard with charts, Pine scripts and alerts"
  homepage "https://degenview.app/"

  livecheck do
    skip "Written by the bump workflow of the tap from the newest final or release candidate."
  end

  auto_updates true
  conflicts_with cask: "degenview"
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
