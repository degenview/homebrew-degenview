# Written by scripts/bump.sh from the degenview/degenview release v0.6.0-rc.25. Do not edit by hand.
cask "degenview@rc" do
  arch arm: "arm64", intel: "x64"

  version "0.6.0-rc.25"
  sha256 arm:   "8a9065b03d961cebfb37d1fca7cc77f8f0836c1b29d5432ee9230cffaf154353",
         intel: "e79ece6952f3c204491233d651568cfca6b4e8290a1333354845886e279bd10b"

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
