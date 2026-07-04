{ pkgs, inputs, ... }:

let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  python = pkgs.python312.overrideAttrs (old: {
    passthru = pkgs.lib.filterAttrs (name: _: name != "doc") old.passthru;
  });

  zen-browser = let version = "1.21.5b"; in pkgs.stdenv.mkDerivation {
    pname = "zen-browser";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
      sha256 = "0dea09bbc5fed9e1e32839f288a609b0b20eb1befed8d4f892e222a65dfaa069";
    };

    icon = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/zen-browser/desktop/dev/docs/assets/zen-dark.svg";
      sha256 = "e33073d00a5b8330b0eb1ac34d574e385cfe7c4012c71d07d4ec8a11b25aee50";
    };

    nativeBuildInputs = with pkgs; [ makeWrapper librsvg ];

    sourceRoot = "zen";

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p \
        $out/lib \
        $out/bin \
        $out/share/applications \
        $out/share/icons/hicolor/128x128/apps \
        $out/share/icons/hicolor/scalable/apps

      cp -r . $out/lib/zen

      rsvg-convert -w 128 -h 128 "$icon" -o $out/share/icons/hicolor/128x128/apps/zen-browser.png
      cp "$icon" $out/share/icons/hicolor/scalable/apps/zen-browser.svg

      makeWrapper $out/lib/zen/zen $out/bin/zen \
        --prefix LD_LIBRARY_PATH : "$out/lib/zen" \
        --prefix MOZ_LEGACY_LIBS : "$out/lib/zen" \
        --prefix PATH : "${pkgs.xdg-utils}/bin"

      cat > $out/share/applications/zen-browser.desktop <<'EOF'
      [Desktop Entry]
      Type=Application
      Name=Zen Browser
      GenericName=Web Browser
      Comment=Experience a calmer internet
      Exec=zen %u
      Icon=zen-browser
      Terminal=false
      Categories=Network;WebBrowser;
      StartupNotify=true
      StartupWMClass=zen
      MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;
      EOF

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Beautifully designed, privacy-focused, Firefox-based browser";
      homepage = "https://zen-browser.app";
      license = licenses.mpl20;
      platforms = [ "x86_64-linux" ];
      mainProgram = "zen";
    };
  };
in
{
  users.users.mame.packages = with pkgs; [
    go
    git
    vim
    neovim
    tmux
    tree
    nodejs
    bun
    pnpm
    python
    uv
    gcc
    gnumake
    pkg-config
    ripgrep
    fd
    jq
    direnv
    nix-direnv
    lazygit
    lazydocker
    lazysql
    ghq
    fzf
    niri
    ghostty
  ] ++ [
    llmAgents.opencode
    llmAgents.grok
    zen-browser
  ];
}
