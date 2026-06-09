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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.7.0/anodizer-0.7.0-darwin-arm64.tar.gz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.7.0/anodizer-0.7.0-linux-arm64.tar.gz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.7.0/anodizer-0.7.0-darwin-amd64.tar.gz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.7.0/anodizer-0.7.0-linux-amd64.tar.gz";
  };
  shaMap = {
    aarch64-darwin = "0gnw632knia3xiyh5v62mhs7y7icx15lqbba08pf9pmmagfp7hhv";
    aarch64-linux = "0m7c5mvhsp78dp2sff64daadwps7d8hfrvwpgq60nrvc26bwpvn0";
    x86_64-darwin = "1363hvp6080nsjvxkicjdif5amgaf1jv0xs4yg4ql7fh0909l51c";
    x86_64-linux = "10syjs8dzay66r1836h3nywlw9d3z4wh6ipqdg7h04bppp98khyy";
  };
in
stdenvNoCC.mkDerivation {
  pname = "anodizer";
  version = "0.7.0";

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
