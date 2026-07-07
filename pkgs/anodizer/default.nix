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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.15.5/anodizer-0.15.5-darwin-arm64-extra.tar.xz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.15.5/anodizer-0.15.5-linux-arm64-extra.tar.xz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.15.5/anodizer-0.15.5-darwin-amd64-extra.tar.xz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.15.5/anodizer-0.15.5-linux-amd64-extra.tar.xz";
  };
  shaMap = {
    aarch64-darwin = "1fx554dzmqxg5dwsicyfsibmazk4ca7wif66a6vvhd7b6z8c12d2";
    aarch64-linux = "0jh6fdf5a84508l2hid9x6pf0pgpc31m8c1q6pp1n0flk8xi8mrv";
    x86_64-darwin = "1z9byih8v3nfasjq8xd7bfn686pi41f0gmnxydb5zzbd2s6n62m2";
    x86_64-linux = "1zyx9msz4z2sraahqylr2kjm99lc6i3ls453vphjbklpbb772f9w";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "anodizer";
    version = "0.15.5";

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
