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
    aarch64-darwin = "https://github.com/tj-smith47/cfgd/releases/download/v0.10.0/cfgd-0.10.0-darwin-arm64.tar.gz";
    aarch64-linux = "https://github.com/tj-smith47/cfgd/releases/download/v0.10.0/cfgd-0.10.0-linux-arm64.tar.gz";
    x86_64-darwin = "https://github.com/tj-smith47/cfgd/releases/download/v0.10.0/cfgd-0.10.0-darwin-amd64.tar.gz";
    x86_64-linux = "https://github.com/tj-smith47/cfgd/releases/download/v0.10.0/cfgd-0.10.0-linux-amd64.tar.gz";
  };
  shaMap = {
    aarch64-darwin = "1irjbixsy7xgzgxdfnbsivr6hj9szzp2cmbyq9aaidiibhikmrma";
    aarch64-linux = "0v1jhp86d63073ahqdlwkz278q1czaq7r3jpglf3k67iaa75bd8p";
    x86_64-darwin = "1b44drqz6xv7gpjy9g1dkcjf6k1yqa4j6r0sqh8rkrcqp6lkd6jj";
    x86_64-linux = "04syyp2y00wz2nzcaha72ckr224m920bxpb4p4sxmr0ii4nw2j4w";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "cfgd";
    version = "0.10.0";

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
      installShellCompletion --cmd cfgd --bash completions/cfgd --zsh completions/_cfgd --fish completions/cfgd.fish
      installManPage man/man1/*
      installManPage man/man1/cfgd.1
      installShellCompletion --bash completions/cfgd --zsh completions/_cfgd --fish completions/cfgd.fish
    '';

    postInstall = ''
      echo "Installed cfgd. Run 'cfgd init' to scaffold a config."
    '';

    meta = {
      description = "Declarative, GitOps-style machine configuration management";
      longDescription = ''
        cfgd manages machine configuration the way GitOps manages clusters:
        declare packages, files, secrets, and system settings in
        version-controlled YAML, and cfgd diffs desired against actual state,
        plans the change set, and reconciles it — one-shot or continuously
        via its daemon. The same binary drives both workstation and
        Kubernetes-node providers.

      '';
      homepage = "https://github.com/tj-smith47/cfgd";
      changelog = "https://github.com/tj-smith47/cfgd/releases/tag/v0.10.0";
      license = with lib.licenses; [mit asl20];
      maintainers = [];
      mainProgram = "cfgd";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
    };
  }
