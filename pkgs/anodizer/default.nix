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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.10.0/anodizer-0.10.0-darwin-arm64-extra.tar.xz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.10.0/anodizer-0.10.0-linux-arm64-extra.tar.xz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.10.0/anodizer-0.10.0-darwin-amd64-extra.tar.xz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.10.0/anodizer-0.10.0-linux-amd64-extra.tar.xz";
  };
  shaMap = {
    aarch64-darwin = "053nqlh099rpqr64908j2sa2vnd3xkv3433ngb4anbqmqnbjwws9";
    aarch64-linux = "1s7p3rx5d3915216mmgxd8kdkfa12prq2jf70sja13fqfr8g2gzq";
    x86_64-darwin = "0wgk3g6savcj5qs7iawi204cfg6iq2a0z996fz8baq19nn53qb7f";
    x86_64-linux = "1sq9k9qli03ryqa3anp6f0ashyrsa0pxz37jvr2wrxrn983xznzn";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "anodizer";
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
