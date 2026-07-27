{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "herdr";
  version = "0.7.5";

  src = fetchurl {
    url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
    sha256 = "0lwjqnajw50rjaxxn5zxqr0r3jmwjyzffc4scwy2sk1y0y435j1x";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/herdr
    chmod +x $out/bin/herdr
  '';

  meta = with lib; {
    description = "Terminal workspace manager for AI coding agents";
    homepage = "https://herdr.dev";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "herdr";
  };
}
