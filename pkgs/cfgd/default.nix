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
    aarch64-darwin = "0ki63hp2si4z9cb63xp82qrq50qqlk3ndj9m6ispsn9508ycpj8c";
    aarch64-linux = "06byzz19zlg859idmapb24dsak9qx164rycb4m7xxd6sy0mjrwqx";
    x86_64-darwin = "16i9q7z39hj1xvi2jqsr8d5fgfymzwcapbh7an4gn8bi1yjdqhy4";
    x86_64-linux = "147p6xhizj19f2f9nzmb6yq53h92ax8c45ia854bklvy3nynd5nd";
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
    platforms = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
  };
}
