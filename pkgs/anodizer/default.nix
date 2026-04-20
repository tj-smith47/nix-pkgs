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
    aarch64-darwin = "029niwz83662n0g944vfxnyb7dcldp1rrb7klplfy94l6vsn2c1r";
    aarch64-linux = "0zxrg171g9cp0z5d13xpzjli5p59nhbgznd3402xq21n78ya2yyp";
    x86_64-darwin = "12xj158nfvyi2z4264gqn492l5h3p7hymzf9mvxh8vn5vhk3rgp7";
    x86_64-linux = "17y1hvz8jvp8vak0yiwxn957sw808cdrh00dzf9ahv6q3jbp45bg";
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
    platforms = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" "x86_64-darwin" ];
  };
}
