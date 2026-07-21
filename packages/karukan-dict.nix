{ stdenvNoCC, fetchurl }:
stdenvNoCC.mkDerivation {
  pname = "karukan-dict";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/togatoga/karukan/releases/download/v0.1.0/dict.tgz";
    hash = "sha256-8ZTSUmv4JmIrxbr3wH51Ja2b3i3GOJbNkpBFKDpK7M0=";
  };

  unpackPhase = ''
    runHook preUnpack
    tar xzf $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/karukan-im
    cp dict.bin $out/share/karukan-im/
    runHook postInstall
  '';
}
