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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.1.0/anodizer-0.1.0-darwin-arm64.tar.gz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.1.0/anodizer-0.1.0-linux-arm64.tar.gz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.1.0/anodizer-0.1.0-darwin-amd64.tar.gz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.1.0/anodizer-0.1.0-linux-amd64.tar.gz";
  };
  shaMap = {
    aarch64-darwin = "1lsr1kk04mvc4bryhn7nxxkgp6p9y1sa0lfw22yqdbab8w082crx";
    aarch64-linux = "0p5pyls72s2g80qqj53lnwg2snbqzylg472zxwmndmryi42y980c";
    x86_64-darwin = "0jxcp4rrmz2msq4m8ky17zs5q1q0rc6cgz6dfis6bmxrjwfdlzh9";
    x86_64-linux = "1w3996zaqhbngl08gyz0rp2rkdak82xrvkkfji78n9haja1hgr70";
  };
in
stdenvNoCC.mkDerivation {
  pname = "anodizer";
  version = "0.1.0";

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
  '';

  meta = {
    description = "A Rust-native release automation tool";
    homepage = "https://github.com/tj-smith47/anodizer";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];
  };
}
