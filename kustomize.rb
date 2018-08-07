class Kustomize < Formula
  desc "Customization of kubernetes YAML configurations"
  homepage "https://github.com/kubernetes-sigs/kustomize"
  url "https://github.com/kubernetes-sigs/kustomize/archive/v1.0.5.tar.gz"
  version "1.0.5"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/kubernetes-sigs/kustomize/").install buildpath.children
    cd "src/github.com/kubernetes-sigs/kustomize/" do
      system "go", "build", "-o", "kustomize"
      bin.install "kustomize"
      pkgshare.install Dir["examples/*"]
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
