{ lib, stdenv, fetchurl, autoPatchelfHook, dpkg, makeWrapper
, alsa-lib, at-spi2-core, cairo, cups, dbus, expat, glib, gtk3, libdrm
, libnotify, libsecret, libxcb, libxkbcommon, libxcomposite, libxdamage
, libxext, libxfixes, libxrandr, mesa, nspr, nss, pango, libudev-zero
, libx11, libxshmfence, libappindicator-gtk3, libxscrnsaver, libxtst, libGL
}:

stdenv.mkDerivation rec {
  pname = "opencode-desktop";
  version = "1.18.1";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-desktop-linux-amd64.deb";
    hash = "sha256-CyEzGdPFGjL6He2euDMQFas0Fgr7z9BFTkF7QS849+E=";
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
    mkdir -p $out/opt/OpenCode $out/bin $out/share
    cp -r extracted/opt/OpenCode/* $out/opt/OpenCode/

    makeWrapper $out/opt/OpenCode/ai.opencode.desktop $out/bin/opencode-desktop \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]}

    mkdir -p $out/share/{icons,applications}
    cp -r extracted/usr/share/icons/hicolor $out/share/icons/ 2>/dev/null || true
    cp extracted/usr/share/applications/*.desktop $out/share/applications/ 2>/dev/null || true

    for f in $out/share/applications/*.desktop; do
      substituteInPlace "$f" --replace-fail "/opt/OpenCode/ai.opencode.desktop" "$out/bin/opencode-desktop"
    done
    runHook postInstall
  '';

  preFixup = ''
    rm -rf $out/opt/OpenCode/resources/app.asar.unpacked/node_modules/@parcel/watcher-linux-x64-musl
    find $out/opt/OpenCode -name '*.musl.node' -delete
  '';

  meta = with lib; {
    description = "AI coding agent desktop app";
    homepage = "https://opencode.ai";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "opencode-desktop";
  };
}
