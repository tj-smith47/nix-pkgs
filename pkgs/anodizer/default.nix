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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.13.1/anodizer-0.13.1-darwin-arm64-extra.tar.xz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.13.1/anodizer-0.13.1-linux-arm64-extra.tar.xz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.13.1/anodizer-0.13.1-darwin-amd64-extra.tar.xz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.13.1/anodizer-0.13.1-linux-amd64-extra.tar.xz";
  };
  shaMap = {
    aarch64-darwin = "0ays0zlsi1cf5gpy89m3pcnzy044z73rnv7r4dixy8i92m5mw5g8";
    aarch64-linux = "1dqqqrnk5bm0vbkjs6gc62f5d1wasn6s5abnn4wdcr96g6l597b6";
    x86_64-darwin = "1dff45jlw5r9w1ig6g0rdhi29x74032f3k0ihq0kag735bbgvf76";
    x86_64-linux = "04zfqa9kl151lzq2kmicqn8di74gx4fdvj6f872y4pxsdkza8z6d";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "anodizer";
    version = "0.13.1";

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
