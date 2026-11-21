# Written by scripts/bump.sh from the degenview/degenview release v0.6.0-rc.33. Do not edit by hand.
cask "degenview@rc" do
  arch arm: "arm64", intel: "x64"

  version "0.6.0-rc.33"
  sha256 arm:   "ef14d30f5a95764f408ae9c3d038497be35f05ce4f8f29816f50486c42fa31f5",
         intel: "368e1cfa6190b4456f18b8507a81f428c6ca5a46883af77e1d76e0e5448dea2f"

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
