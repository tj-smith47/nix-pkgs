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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.28.0/anodizer-0.28.0-darwin-arm64-extra.tar.xz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.28.0/anodizer-0.28.0-linux-arm64-extra.tar.xz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.28.0/anodizer-0.28.0-darwin-amd64-extra.tar.xz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.28.0/anodizer-0.28.0-linux-amd64-extra.tar.xz";
  };
  shaMap = {
    aarch64-darwin = "1vw1aw80qpcri1mipmb405p22gr6md31lx8aaaac9n714l38p2x0";
    aarch64-linux = "01fsbv9npmrx9czqrjjrxldd2k9p5irc0pmgrk7lqg8j0i0nd0s7";
    x86_64-darwin = "08xgcpcck2qzn3wrx15x3r5i49r07zspsz1mali925prkqq34r68";
    x86_64-linux = "1d3cgym9qq26nadm6gfhjils756vsv5yc3xxrw340jhq3zbf7ps7";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "anodizer";
    version = "0.28.0";

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
      runHook preInstall
      mkdir -p $out/bin
      cp -vr ./anodizer $out/bin/anodizer
      chmod +x $out/bin/anodizer
      installManPage share/man/man1/anodizer.1
      runHook postInstall
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
