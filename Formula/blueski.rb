class Blueski < Formula
  desc "AppleScript-only macOS Messages send/receive daemon"
  homepage "https://github.com/looskis/blueski"
  url "https://github.com/looskis/blueski/releases/download/v0.1.0/blueski-0.1.0.tar.gz"
  sha256 "5c64441f820268ea84f65300a98e8642caa6caf42447d7ead8a6ad72d0e535a1"
  license "MIT"
  head "https://github.com/looskis/blueski.git", branch: "main"

  depends_on "rust" => :build
  depends_on :macos

  on_macos do
    depends_on macos: :monterey
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Before starting Blueski, grant its macOS permissions:
        #{opt_bin}/blueski setup

      Then start it at login with:
        brew services start blueski
    EOS
  end

  service do
    run [opt_bin/"blueski", "run"]
    keep_alive true
    log_path var/"log/blueski.log"
    error_log_path var/"log/blueski.err"
    environment_variables PATH: std_service_path_env
  end

  test do
    assert_match "AppleScript-only", shell_output("#{bin}/blueski --help")
  end
end
