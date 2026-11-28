# Written by scripts/bump.sh from the degenview/degenview release v0.6.0-rc.38. Do not edit by hand.
cask "degenview@rc" do
  arch arm: "arm64", intel: "x64"

  version "0.6.0-rc.38"
  sha256 arm:   "4a5e3733cd570ba210923df8d73ef3c0ea51ef75fb71935bc3b7964297603f40",
         intel: "67d9c6c5db068f7eb5333a5d0b2d91a671143435b628886ebb898a90a8f7b9a5"

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
