{ lib, stdenv, fetchurl, autoPatchelfHook, dpkg, makeWrapper
, alsa-lib, at-spi2-core, cairo, cups, dbus, expat, glib, gtk3, libdrm
, libnotify, libsecret, libxcb, libxkbcommon, libxcomposite, libxdamage
, libxext, libxfixes, libxrandr, mesa, nspr, nss, pango, libudev-zero
, libx11, libxshmfence, libappindicator-gtk3, libxscrnsaver, libxtst, libGL
}:

stdenv.mkDerivation rec {
  pname = "orca-desktop";
  version = "1.4.159";

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-ide_${version}_amd64.deb";
    hash = "sha256-jtuIP6HWoB7DwqEf3+yiXC7Uha8az9/VIMs9+iKUr2I=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    alsa-lib at-spi2-core cairo cups dbus expat glib gtk3 libdrm
    libnotify libsecret libxcb libxkbcommon libxcomposite libxdamage
    libxext libxfixes libxrandr mesa nspr nss pango libudev-zero
    libx11 libxshmfence libappindicator-gtk3 libxscrnsaver libxtst libGL
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg --extract $src ./extracted
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt/Orca $out/bin $out/share
    cp -r extracted/opt/Orca/* $out/opt/Orca/

    makeWrapper $out/opt/Orca/orca-ide $out/bin/orca-desktop \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]}

    mkdir -p $out/share/{icons,applications}
    cp -r extracted/usr/share/icons/hicolor $out/share/icons/ 2>/dev/null || true
    cp extracted/usr/share/applications/orca-ide.desktop $out/share/applications/ 2>/dev/null || true

    for f in $out/share/applications/*.desktop; do
      substituteInPlace "$f" --replace-fail "/opt/Orca/orca-ide" "$out/bin/orca-desktop"
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "AI Orchestrator for running coding agents in parallel";
    homepage = "https://github.com/stablyai/orca";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "orca-desktop";
  };
}
