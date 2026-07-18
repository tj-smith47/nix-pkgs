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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.22.0/anodizer-0.22.0-darwin-arm64-extra.tar.xz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.22.0/anodizer-0.22.0-linux-arm64-extra.tar.xz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.22.0/anodizer-0.22.0-darwin-amd64-extra.tar.xz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.22.0/anodizer-0.22.0-linux-amd64-extra.tar.xz";
  };
  shaMap = {
    aarch64-darwin = "014ihnvm2q0ag07797yb03qhmpxqnji8kfnzihwq4dsg2jshyys0";
    aarch64-linux = "0dchkxbzxqan49sfxg61qlaslvrv7gb49i0r9c4d74f191jpy7dr";
    x86_64-darwin = "0mif0cxqq5g15hxx5pbz8ppxnv9vyh7j05vfb6wx4ihmbjfskkjf";
    x86_64-linux = "15p950642bd434lfnwk5gvlm8sm1k58w717kdyz0y3m96vrihhky";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "anodizer";
    version = "0.22.0";

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
      cp -vr ./anodizer $out/bin/anodizer
      chmod +x $out/bin/anodizer
      installManPage share/man/man1/anodizer.1
    '';

    postInstall = ''
      echo "Installed anodizer. Run 'anodizer init' to scaffold a config."
    '';

    meta = {
      description = "A Rust-native release automation tool";
      longDescription = ''
        Anodizer is a Rust-native release-automation tool: it builds, archives,
        packages, signs, and publishes Rust binaries in one deterministic
        pipeline. It mirrors GoReleaser's behavior (OSS and Pro) while adding
        Rust-first conveniences, and produces signed releases across crates.io,
        Homebrew, Scoop, winget, AUR, Nix, and OCI registries.

      '';
      homepage = "https://github.com/tj-smith47/anodizer";
      changelog = "https://github.com/tj-smith47/anodizer/releases";
      license = with lib.licenses; [mit asl20];
      maintainers = with lib.maintainers; [tj-smith47];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
    };
  }
