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
    aarch64-darwin = "1ymdciq67m08x6rpb47j1qw0q71ygz2clq29wrik77qif8q4l4h2";
    aarch64-linux = "0jl9bancdkhbgyng2mqmbqivdb0fwaa1d1da08ddw43n1jm998ir";
    x86_64-darwin = "1vzh8a3kx65v2d0960a30m3akzd41pkrdhh0vj2jkbb54sm5wwv7";
    x86_64-linux = "13ii7z46b5f53fdf40wj0dj0jzxpzaf1qwyhqa86567c2fg38rm8";
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
    platforms = [ "x86_64-darwin" "x86_64-linux" "aarch64-darwin" "aarch64-linux" ];
  };
}
