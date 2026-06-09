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
    aarch64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.7.0/anodizer-0.7.0-darwin-arm64.tar.gz";
    aarch64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.7.0/anodizer-0.7.0-linux-arm64.tar.gz";
    x86_64-darwin = "https://github.com/tj-smith47/anodizer/releases/download/v0.7.0/anodizer-0.7.0-darwin-amd64.tar.gz";
    x86_64-linux = "https://github.com/tj-smith47/anodizer/releases/download/v0.7.0/anodizer-0.7.0-linux-amd64.tar.gz";
  };
  shaMap = {
    aarch64-darwin = "1d4ndjjbx72l8lws63rgv43i8qy2y3y9s66k5hjjqxg6hnc89f8n";
    aarch64-linux = "1gp4kjlp8z7bk6smmz2a4jsg5j1wql78qg1hi1rmz0m49bay80i0";
    x86_64-darwin = "0gvw6n2j5907qhx2zqg5ksz2l30cjqj8kbyh7pq788xpyp8ahcnp";
    x86_64-linux = "12j5b5nxd5sjfyg6pkfxriif2ijhis6jn74ddhfqx2sh7q65vbhg";
  };
in
stdenvNoCC.mkDerivation {
  pname = "anodizer";
  version = "0.7.0";

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
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-darwin" "aarch64-darwin" "aarch64-darwin" "x86_64-darwin" "x86_64-darwin" "x86_64-darwin" "aarch64-linux" "aarch64-linux" "aarch64-linux" "x86_64-linux" "x86_64-linux" "x86_64-linux" ];
  };
}
