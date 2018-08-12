require 'time'

class Lazygit < Formula
  desc "Customization of kubernetes YAML configurations"
  homepage "https://github.com/jesseduffield/lazygit/"
  url "https://github.com/jesseduffield/lazygit/archive/v0.1.55.tar.gz"
  sha256 "c77f6f2176a850d324992e502e6088a3d2dbc4faa15898af24d68b01e33acef3"
  version "0.1.55"

  depends_on "go" => :build

  def install
    build_date = Time.now.utc.iso8601

    ENV["GOPATH"] = buildpath
    ENV["GOOS"] = 'darwin'
    ENV["GOARCH"] = 'amd64'
    ENV["CGO_ENABLED"] = '1'

    cd "src/github.com/jesseduffield/lazygit/" do
      commit_hash=`git rev-parse HEAD`
    end

    go_build_ldflags = [
      "-X github.com/jesseduffield/lazygit/main.buildDate=#{build_date}",
      "-X github.com/jesseduffield/lazygit/main.version=0.1.55",
      "-X github.com/jesseduffield/lazygit/main.commit=#{commit_hash}",
    ].join(' ')

    (buildpath/"src/github.com/jesseduffield/lazygit/").install buildpath.children
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
