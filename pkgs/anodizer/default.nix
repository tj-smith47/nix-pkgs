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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.9.1/anodizer-0.9.1-darwin-arm64.tar.gz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.9.1/anodizer-0.9.1-linux-arm64.tar.gz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.9.1/anodizer-0.9.1-darwin-amd64.tar.gz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.9.1/anodizer-0.9.1-linux-amd64.tar.gz";
  };
  shaMap = {
    aarch64-darwin = "1lv88zlp8j2zzm6my15s64yyvyg8pvj7dvw07zydrqplg2vk3pq9";
    aarch64-linux = "1f6qb4l0n191h37nlblf5687rlnalmqjmipmfncq3ipd2b9qs7a3";
    x86_64-darwin = "1azwji6c34fbzg16sa61z29z3nbb0b1hs7crla72y48v5q6zdip1";
    x86_64-linux = "0mp3ykcsy82z9ba9s8z9y1nqs5rjjlvdsz95xm4p1620cjfirpxz";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "anodizer";
    version = "0.9.1";

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
      homepage = "https://github.com/tj-smith47/anodizer";
      license = lib.licenses.mit;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = ["aarch64-darwin" "aarch64-darwin" "aarch64-darwin" "x86_64-darwin" "x86_64-darwin" "x86_64-darwin" "aarch64-linux" "aarch64-linux" "aarch64-linux" "x86_64-linux" "x86_64-linux" "x86_64-linux"];
    };
  }
