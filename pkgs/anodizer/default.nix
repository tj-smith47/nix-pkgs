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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.8.0/anodizer-0.8.0-darwin-arm64.tar.gz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.8.0/anodizer-0.8.0-linux-arm64.tar.gz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.8.0/anodizer-0.8.0-darwin-amd64.tar.gz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.8.0/anodizer-0.8.0-linux-amd64.tar.gz";
  };
  shaMap = {
    aarch64-darwin = "0x5lg5zih6f1kcqv8n3lrqcbk42ng45id54jxdhsa39z381cxn30";
    aarch64-linux = "06vzmzwq7bvvg1gvavhdxc920qbsypqaa2i9imdbz8kv3ir7iqpr";
    x86_64-darwin = "1bv6x9fa3bbv60wa1aq50axil2z3cppfd4dj7d1wr93xn66is69z";
    x86_64-linux = "0x13g8jfyaf4lxvsqkibbr3asnvl51mkffm883sbhacv2xj9xc73";
  };
in
stdenvNoCC.mkDerivation {
  pname = "anodizer";
  version = "0.8.0";

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
    platforms = [ "aarch64-darwin" "aarch64-darwin" "aarch64-darwin" "x86_64-darwin" "x86_64-darwin" "x86_64-darwin" "aarch64-linux" "aarch64-linux" "aarch64-linux" "x86_64-linux" "x86_64-linux" "x86_64-linux" ];
  };
}
