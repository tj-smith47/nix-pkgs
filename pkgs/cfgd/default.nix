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
    aarch64-darwin = "https://github.com/tj-smith47/cfgd/releases/download/v0.3.5/cfgd-0.3.5-darwin-arm64.tar.gz";
    aarch64-linux = "https://github.com/tj-smith47/cfgd/releases/download/v0.3.5/cfgd-0.3.5-linux-arm64.tar.gz";
    x86_64-darwin = "https://github.com/tj-smith47/cfgd/releases/download/v0.3.5/cfgd-0.3.5-darwin-amd64.tar.gz";
    x86_64-linux = "https://github.com/tj-smith47/cfgd/releases/download/v0.3.5/cfgd-0.3.5-linux-amd64.tar.gz";
  };
  shaMap = {
    aarch64-darwin = "07v00rmglwgbrjjy6j7zp1fxanmpczhmp28xbg1dknrv3gwj9v83";
    aarch64-linux = "18sl8i9xpgah48g7lhhqg00ddkv5cdpsqm5nx1b4hd67aixnfrxy";
    x86_64-darwin = "1j0y50kj24g4ihy7j1803z9xcrx7z9dy2adnj60x08ml9p3sa1ba";
    x86_64-linux = "1f04k25h44gg22sjx3m3l9svbagcqxdkily5rbf6yr09wa353cg8";
  };
in
stdenvNoCC.mkDerivation {
  pname = "cfgd";
  version = "0.3.5";

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
    cp -vr ./cfgd $out/bin/cfgd
    chmod +x $out/bin/cfgd
  '';

  meta = {
    description = "Declarative, GitOps-style machine configuration management";
    homepage = "https://github.com/tj-smith47/cfgd";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" "x86_64-darwin" ];
  };
}
