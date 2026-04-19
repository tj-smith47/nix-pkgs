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
    aarch64-darwin = "1f9g1h64lyj272266nqylq4x00cxv28n2cnp149spw4qw9rpv6ds";
    aarch64-linux = "15ck7ybbp2yiminzq3ig2a7c98lm9p326fv2hr5lx6v54i8gzb23";
    x86_64-darwin = "1xqprd0lqbkbfcc3wxx2gzib0fv51zjbj6gvd3kjdv1xr2x5sb54";
    x86_64-linux = "00cgvvzrd63204kbqk1zy39yzbbsg7ng72w8dx2qz71gl38y393a";
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
    platforms = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
  };
}
