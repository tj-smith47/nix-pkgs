{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  stdenv,
  autoPatchelfHook,
  installShellFiles,
}: let
  selectSystem = attrs: attrs.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
  urlMap = {
    aarch64-darwin = "https://github.com/tj-smith47/cfgd/releases/download/v0.4.0/cfgd-0.4.0-darwin-arm64.tar.gz";
    aarch64-linux = "https://github.com/tj-smith47/cfgd/releases/download/v0.4.0/cfgd-0.4.0-linux-arm64.tar.gz";
    x86_64-darwin = "https://github.com/tj-smith47/cfgd/releases/download/v0.4.0/cfgd-0.4.0-darwin-amd64.tar.gz";
    x86_64-linux = "https://github.com/tj-smith47/cfgd/releases/download/v0.4.0/cfgd-0.4.0-linux-amd64.tar.gz";
  };
  shaMap = {
    aarch64-darwin = "151ajnhjif18favyiy9yqyqnsmc27xn8r2viivc9s9zvmz87vl73";
    aarch64-linux = "1fqd6x1jrmqbvwp1513dh6kdikmqdilvpmai4ddf70d8li8j30q5";
    x86_64-darwin = "16qi7zk64ik39cnydxkqsiwd94l8vd2vddpxdi4rhn7q96h05dhf";
    x86_64-linux = "1v6alrj4p33a1pq00mgs26fia6g986a9x6dvqb4ki36wwgsd83v4";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "cfgd";
    version = "0.4.0";

    src = fetchurl {
      url = selectSystem urlMap;
      sha256 = selectSystem shaMap;
    };

    sourceRoot = ".";

    nativeBuildInputs =
      [
        installShellFiles
        unzip
      ]
      ++ lib.optionals stdenvNoCC.isLinux [autoPatchelfHook];

    buildInputs = lib.optionals stdenvNoCC.isLinux [
      stdenv.cc.cc.lib
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp -vr ./cfgd $out/bin/cfgd
      chmod +x $out/bin/cfgd
      installManPage share/man/man1/cfgd.1
    '';

    postInstall = ''
      echo "Installed cfgd. Run 'cfgd init' to scaffold a config."
    '';

    meta = {
      description = "Declarative, GitOps-style machine configuration management";
      homepage = "https://github.com/tj-smith47/cfgd";
      license = lib.licenses.mit;
      mainProgram = "cfgd";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = ["aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
    };
  }
