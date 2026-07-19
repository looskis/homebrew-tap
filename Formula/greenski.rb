class Greenski < Formula
  desc "Lightweight WhatsApp linked-device send/receive daemon"
  homepage "https://github.com/looskis/greenski"
  url "https://github.com/looskis/greenski/releases/download/v0.1.0/greenski-0.1.0.tar.gz"
  sha256 "6be22abc8f902b8dcf00bba487e3da9b329cf6c0f1653c0c23b2b203b92a5582"
  license "MIT"
  head "https://github.com/looskis/greenski.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Start Greenski at login, then pair it as a WhatsApp linked device:
        brew services start greenski
        #{opt_bin}/greenski pair

      Greenski uses WhatsApp's unofficial linked-device protocol. Protocol
      changes can break it, and automated messaging may trigger restrictions.
    EOS
  end

  service do
    run [opt_bin/"greenski", "run"]
    keep_alive true
    log_path var/"log/greenski.log"
    error_log_path var/"log/greenski.err"
    environment_variables PATH: std_service_path_env
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/greenski --version")
  end
end
