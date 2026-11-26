# Written by scripts/bump.sh from the degenview/degenview release v0.6.0-rc.36. Do not edit by hand.
cask "degenview@rc" do
  arch arm: "arm64", intel: "x64"

  version "0.6.0-rc.36"
  sha256 arm:   "c3650e82462d7a4a8e016a5d6f5302868ed5a9ba0746886693f758ccf87feba5",
         intel: "cf329d74f18751570bd5bb6244a174068bb82dd541b73690602f0ee63b64e71a"

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
