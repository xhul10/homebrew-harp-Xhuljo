# Code generated by Harp build tool
class HarpServer < Formula
  desc "Harp Crate Server"
  homepage "https://github.com/elastic/harp"
  license "Apache 2.0"
  bottle :unneeded

  # Stable build
  stable do
    if OS.mac?
      url "https://github.com/elastic/harp/releases/download/cmd%2Fharp-server%2Fv0.1.9/harp-server-darwin-amd64-v0.1.9.tar.xz"
      sha256 "cbea86ae7cd75e25018ec80b4bb400ae1335e39f8c6856455ab80d9daccd0fb8"
    elsif OS.linux?
      url "https://github.com/elastic/harp/releases/download/cmd%2Fharp-server%2Fv0.1.9/harp-server-linux-amd64-v0.1.9.tar.xz"
      sha256 "6642fdf39e878020aaad42a852626625bf7ef3eb5d4e3e2da06e962637eb0e7c"
    end
  end

  # Source definition
  head do
    url "https://github.com/elastic/harp.git", :branch => "main"

    # build dependencies
    depends_on "go" => :build
    depends_on "mage" => :build
  end

  def install
    ENV.deparallelize

    unless build.head?
      # Install binaries
      if OS.mac?
        bin.install "harp-server-darwin-amd64" => "harp-server"
      elsif OS.linux?
        bin.install "harp-server-linux-amd64" => "harp-server"
      end
    else
      # Prepare build environment
      ENV["GOPATH"] = buildpath
      (buildpath/"src/github.com/elastic/harp").install Dir["{*,.git,.gitignore}"]

      # Mage tools
      ENV.prepend_path "PATH", buildpath/"tools/bin"

      # In github.com/elastic/harp command
      cd "src/github.com/elastic/harp/cmd/harp-server" do
        system "go", "mod", "vendor"
        system "mage", "compile"
      end

      # Install builded command
      cd "src/github.com/elastic/harp/cmd/harp-server/bin" do
        # Install binaries
        if OS.mac?
          bin.install "harp-server-darwin-amd64" => "harp-server"
        elsif OS.linux?
          bin.install "harp-server-linux-amd64" => "harp-server"
        end
      end
    end

    # Final message
    ohai "Install success!"
  end

  def caveats
    <<~EOS
      If you have previously built harp-server from source, make sure you're not using
      $GOPATH/bin/harp-server instead of this one. If that's the case you can simply run
      rm -f $GOPATH/bin/harp-server
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/harp-server version")
  end
end
