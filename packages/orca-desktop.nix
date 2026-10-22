{ lib, stdenv, fetchurl, autoPatchelfHook, dpkg, makeWrapper
, alsa-lib, at-spi2-core, cairo, cups, dbus, expat, glib, gtk3, libdrm
, libnotify, libsecret, libxcb, libxkbcommon, libxcomposite, libxdamage
, libxext, libxfixes, libxrandr, mesa, nspr, nss, pango, libudev-zero
, libx11, libxshmfence, libappindicator-gtk3, libxscrnsaver, libxtst, libGL
, python312, gobject-introspection, gdk-pixbuf, harfbuzz, xdotool, xprop, xwininfo, wmctrl, scrot, xclip
}:

let
  computerPython = python312.withPackages (ps: with ps; [ pygobject3 pyatspi pillow ]);
  computerPath = lib.makeBinPath [ computerPython xdotool xprop xwininfo wmctrl scrot xclip ];
  introspectionLibraries = map lib.getLib [
    at-spi2-core gtk3 glib gobject-introspection gdk-pixbuf pango harfbuzz
  ];
  typelibPath = lib.makeSearchPath "lib/girepository-1.0" introspectionLibraries;
in
stdenv.mkDerivation rec {
  pname = "orca-desktop";
  version = "1.4.237";

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-ide_${version}_amd64.deb";
    hash = "sha256-KW/9FDRWEr5wygnpq0D3/7t/hC+1eU4ebB68MkNgy1w=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  # Remote payloads include other architectures and musl hosts. Only patch
  # the local app; the templates must retain their upstream dependencies.
  dontAutoPatchelf = true;
  dontStrip = true;
  postFixup = ''
    mv $out/opt/Orca/resources/orcad-template "$TMPDIR/orcad-template"
    autoPatchelf $out
    mv "$TMPDIR/orcad-template" $out/opt/Orca/resources/orcad-template
  '';

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

    # Keep Linux key synthesis consistent with the documented CLI key names.
    patch -d $out/opt/Orca -p1 < ${./orca-linux-keyboard.patch}

    makeWrapper $out/opt/Orca/orca-ide $out/bin/orca-desktop \
      --add-flags "--no-sandbox --force-renderer-accessibility" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath ([ libGL libnotify ] ++ introspectionLibraries)} \
      --prefix GI_TYPELIB_PATH : ${typelibPath} \
      --prefix PATH : ${computerPath} \
      --unset TMUX \
      --unset TMUX_PANE

    # Expose Orca's command-line client separately from the desktop launcher.
    makeWrapper $out/opt/Orca/resources/bin/orca-ide $out/bin/orca \
      --prefix GI_TYPELIB_PATH : ${typelibPath} \
      --prefix PATH : ${computerPath}
    ln -s orca $out/bin/orca-ide

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
