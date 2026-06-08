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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.6.0/anodizer-0.6.0-darwin-arm64.tar.gz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.6.0/anodizer-0.6.0-linux-arm64.tar.gz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.6.0/anodizer-0.6.0-darwin-amd64.tar.gz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.6.0/anodizer-0.6.0-linux-amd64.tar.gz";
  };
  shaMap = {
    aarch64-darwin = "1dgsdqd0kf60lh6fkldpmmsgmy1garpkg08aa19sbd4s42jvjjki";
    aarch64-linux = "14z1yygn0qf0p5mp8z460gc31h6rs4d3d5fg3xaaam7xds8vmcsw";
    x86_64-darwin = "1zkkn9qgkz1a1jnq47b9zzqld8m9vq0i18f0a2d9mnk62n3vip0q";
    x86_64-linux = "17216kk447al0zw9a6d4qy32zgxgw52w7im791vr0lnz3cyb6avm";
  };
in
stdenvNoCC.mkDerivation {
  pname = "anodizer";
  version = "0.6.0";

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
