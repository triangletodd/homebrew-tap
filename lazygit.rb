require 'time'
require 'json'
require 'net/http'

class Lazygit < Formula
  desc "A simple terminal UI for git commands, written in Go with the gocui library"
  homepage "https://github.com/jesseduffield/lazygit/"
  url "https://github.com/jesseduffield/lazygit/archive/v0.1.55.tar.gz"
  sha256 "c77f6f2176a850d324992e502e6088a3d2dbc4faa15898af24d68b01e33acef3"
  version "0.1.55"

  depends_on "go" => :build

  def install
    build_date = Time.now.utc.iso8601

    sha_uri = URI("https://api.github.com/repos/jesseduffield/lazygit/git/refs/tags/v#{version}")
    sha_json = Net::HTTP.get(sha_uri)
    sha_obj = JSON.parse(sha_json)
    sha = sha_obj['object']['sha']


    ENV["GOPATH"] = buildpath
    ENV["GOOS"] = 'darwin'
    ENV["GOARCH"] = 'amd64'
    ENV["CGO_ENABLED"] = '1'

    (buildpath/"src/github.com/jesseduffield/lazygit/").install buildpath.children

    go_build_ldflags = [
      "-X main.date=#{build_date}",
      "-X main.version=#{version}",
      "-X main.commit=#{sha}",
    ].join(' ')

    cd "src/github.com/jesseduffield/lazygit/" do
      system "go build -v -o lazygit -ldflags \"#{go_build_ldflags}\""
      bin.install "lazygit"
      prefix.install_metafiles
    end
  end

  test do
    system bin/"lazygit", "version"
  end
end
