class Blueski < Formula
  desc "AppleScript-only macOS Messages send/receive daemon"
  homepage "https://github.com/looskis/blueski"
  url "https://github.com/looskis/blueski/releases/download/v0.1.2/blueski-0.1.2.tar.gz"
  sha256 "3e518dca4165d6064f38bd3653feee059e2c3e54ac1f31e8f766f4e9c7401635"
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
      Before starting Blueski, grant its macOS permissions:
        #{opt_bin}/blueski setup

      Full Disk Access and Automation are attached to:
        #{opt_prefix}/Blueski.app

      Then start it at login with:
        brew services start blueski
    EOS
  end

  service do
    run [opt_prefix/"Blueski.app/Contents/MacOS/blueski", "run"]
    keep_alive true
    log_path var/"log/blueski.log"
    error_log_path var/"log/blueski.err"
    environment_variables PATH: std_service_path_env
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
