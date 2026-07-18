class Taski < Formula
  desc "Safe macOS Reminders task daemon and CLI"
  homepage "https://github.com/looskis/taski"
  url "https://github.com/looskis/taski/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "33a65a5797509113ffde37a6d5a47e004e1a627ebe23a9b309ea3c40713e2daf"
  revision 1

  depends_on macos: :sonoma
  uses_from_macos "swift" => :build, since: :sonoma

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release", "--product", "taski"

    app = libexec/"Taski.app"
    (app/"Contents/MacOS").install ".build/release/taski"
    (app/"Contents/Resources").mkpath
    (app/"Contents").install "Packaging/Info.plist"

    system "codesign", "--force", "--options", "runtime", "--timestamp=none",
           "--entitlements", buildpath/"Packaging/Taski.entitlements", "--sign", "-", app

    bin.install_symlink libexec/"Taski.app/Contents/MacOS/taski"
  end

  def caveats
    <<~EOS
      Finish the one-time interactive setup, then start the daemon:
        taski setup
        brew services start taski
        taski status
    EOS
  end

  service do
    run [opt_libexec/"Taski.app/Contents/MacOS/taski", "daemon"]
    keep_alive successful_exit: false
    process_type :background
    log_path var/"log/taski.log"
    error_log_path var/"log/taski.error.log"
  end

  test do
    assert_match "taski — safe Reminders task daemon", shell_output("#{bin}/taski help")
    system "codesign", "--verify", "--deep", "--strict", libexec/"Taski.app"
  end
end
