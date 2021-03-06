require 'time'

class Kustomize < Formula
  desc "Customization of kubernetes YAML configurations"
  homepage "https://github.com/kubernetes-sigs/kustomize"
  url "https://github.com/kubernetes-sigs/kustomize/archive/v1.0.5.tar.gz"
  sha256 "2afbd060c831aa850d739a83bb5376d2c8c5591ccbbac7be0ae785022aaed5f7"
  version "1.0.5"

  depends_on "go" => :build

  def install
    build_date = Time.now.utc.iso8601

    ENV["GOPATH"] = buildpath
    ENV["GOOS"] = 'darwin'
    ENV["GOARCH"] = 'amd64'
    ENV["CGO_ENABLED"] = '1'

    go_build_ldflags = [
      "-X github.com/kubernetes-sigs/kustomize/pkg/commands.kustomizeVersion=#{version}",
      "-X github.com/kubernetes-sigs/kustomize/pkg/commands.goos=#{ENV['GOOS']}",
      "-X github.com/kubernetes-sigs/kustomize/pkg/commands.goarch=#{ENV['GOARCH']}",
      "-X github.com/kubernetes-sigs/kustomize/pkg/commands.gitCommit=#{version}",
      "-X github.com/kubernetes-sigs/kustomize/pkg/commands.buildDate=#{build_date}"
    ].join(' ')

    (buildpath/"src/github.com/kubernetes-sigs/kustomize/").install buildpath.children
    cd "src/github.com/kubernetes-sigs/kustomize/" do
      system "go build -v -o kustomize -ldflags \"#{go_build_ldflags}\""
      bin.install "kustomize"
      pkgshare.install Dir["examples"]
      prefix.install_metafiles
    end
  end

  test do
    system bin/"kustomize", "version"

    cd pkgshare/"examples/helloWorld" do
      system bin/"kustomize", "build"
    end
  end
end
