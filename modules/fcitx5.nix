{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
      waylandFrontend = true;
    };
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  home-manager.users.mame = { ... }: {
    # fcitx5: profile (mozc + keyboard-us)
    xdg.configFile."fcitx5/profile".text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=mozc

      [Groups/0/Items/0]
      Name=keyboard-us
      Layout=

      [Groups/0/Items/1]
      Name=mozc
      Layout=

      [GroupOrder]
      0=Default
    '';

    # 既定の Ctrl+Space トグルを無効化
    xdg.configFile."fcitx5/config".text = ''
      [Hotkey]
      TriggerKeys=
      EnumeratedHotkeys."0"=
      EnumeratedHotkeys."1"=
    '';

    # imselector: Alt_R で 2番目のIME (mozc=日本語=activate)、
    #             Alt_L で 1番目のIME (keyboard-us=英語=deactivate) に切替
    xdg.configFile."fcitx5/conf/imselector.conf".text = ''
      [Addon/imselector]
      SwitchKey.0=Alt_L
      SwitchKey.1=Alt_R
    '';
  };
}
