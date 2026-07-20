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
    aarch64-darwin = "https://github.com/tj-smith47/cfgd/releases/download/v0.6.0/cfgd-0.6.0-darwin-arm64.tar.gz";
    aarch64-linux = "https://github.com/tj-smith47/cfgd/releases/download/v0.6.0/cfgd-0.6.0-linux-arm64.tar.gz";
    x86_64-darwin = "https://github.com/tj-smith47/cfgd/releases/download/v0.6.0/cfgd-0.6.0-darwin-amd64.tar.gz";
    x86_64-linux = "https://github.com/tj-smith47/cfgd/releases/download/v0.6.0/cfgd-0.6.0-linux-amd64.tar.gz";
  };
  shaMap = {
    aarch64-darwin = "0p690mq7yw3f9nqsm9667wh8lscvqxc8f2r6nx5px4hqkw0i41yi";
    aarch64-linux = "0hznmdcq65334fm4lirvbnzf2pb71g7f5d01fqr42zlkhcasl5m1";
    x86_64-darwin = "1v5q8bfa2xy73xcvar7gk1jfhnx25fv1yp9nvh53i6r7x3jvzvla";
    x86_64-linux = "0fphpciffvhz24ik09a46vgflf15nk8rzhfizmmc5cwi3i116apm";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "cfgd";
    version = "0.6.0";

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
      changelog = "https://github.com/tj-smith47/cfgd/releases/tag/v0.6.0";
      license = with lib.licenses; [mit asl20];
      maintainers = [];
      mainProgram = "cfgd";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
    };
  }
