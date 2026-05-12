{ lib
, stdenvNoCC
, fetchurl
, unzip
, stdenv
, autoPatchelfHook
, installShellFiles
}:

let
  selectSystem = attrs: attrs.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
  urlMap = {
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.2.0/anodizer-0.2.0-darwin-arm64-extra.tar.zst";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.2.0/anodizer-0.2.0-linux-arm64-extra.tar.zst";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.2.0/anodizer-0.2.0-darwin-amd64-extra.tar.zst";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.2.0/anodizer-0.2.0-linux-amd64-extra.tar.zst";
  };
  shaMap = {
    aarch64-darwin = "1dka8yr7vws7671gvg5xyxm5s0f18595kz7v1r1cp93kjsksr8b2";
    aarch64-linux = "0ikxhd00y49z7b8hpkxarbc7ayvqb1hsdr9p7vy1y4hjhd5bd4d5";
    x86_64-darwin = "1x600zly6nfnrw8llfya30mrwndsg5i8abwlkrqrljhbwjx69ayb";
    x86_64-linux = "0jv8iyn59m3jg3rhmyc7i1h04klp598vil2b5vfpvfcafqn71fga";
  };
in
stdenvNoCC.mkDerivation {
  pname = "anodizer";
  version = "0.2.0";

  src = fetchurl {
    url = selectSystem urlMap;
    sha256 = selectSystem shaMap;
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    installShellFiles
    unzip
  ] ++ lib.optionals stdenvNoCC.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenvNoCC.isLinux [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./anodizer $out/bin/anodizer
    chmod +x $out/bin/anodizer
    installManPage share/man/man1/anodizer.1
  '';

  postInstall = ''
    echo "Installed anodizer. Run 'anodizer init' to scaffold a config."
  '';

  meta = {
    description = "A Rust-native release automation tool";
    homepage = "https://github.com/tj-smith47/anodizer";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-linux" "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-darwin" "aarch64-darwin" "x86_64-linux" "x86_64-linux" "x86_64-darwin" "x86_64-darwin" "aarch64-linux" "aarch64-linux" ];
  };
}
