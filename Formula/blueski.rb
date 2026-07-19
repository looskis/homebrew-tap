class Blueski < Formula
  desc "AppleScript-only macOS Messages send/receive daemon"
  homepage "https://github.com/looskis/blueski"
  url "https://github.com/looskis/blueski/releases/download/v0.1.4/blueski-0.1.4.tar.gz"
  sha256 "ebcb2e7189146f9725aee448ec51fb02f6192246a379099856cc80becfe83b6f"
  license "MIT"
  head "https://github.com/looskis/blueski.git", branch: "main"

  depends_on "rust" => :build
  depends_on :macos

  on_macos do
    depends_on macos: :monterey
  end

  def install
    ENV["SIGN_ID"] = "-"
    system "scripts/bundle.sh", "release"

    prefix.install "dist/Blueski.app"
    bin.install_symlink prefix/"Blueski.app/Contents/MacOS/blueski"
  end

  def caveats
    <<~EOS
      Complete Blueski's one-command setup:
        #{opt_bin}/blueski setup

      Full Disk Access and Automation are attached to:
        #{opt_prefix}/Blueski.app
    EOS
  end

  test do
    app = prefix/"Blueski.app"
    assert_predicate app, :directory?
    bundle_id = shell_output(
      "/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' #{app}/Contents/Info.plist",
    ).strip
    assert_equal "com.looskis.blueski", bundle_id
    system "codesign", "--verify", "--deep", "--strict", app
    assert_match version.to_s, shell_output("#{bin}/blueski --version")
  end
end
