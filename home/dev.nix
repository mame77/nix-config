{ pkgs, ... }:

{
  # tmux reads ~/.tmux.conf directly (NOT XDG), so use home.file.
  home.file.".tmux.conf".source = ./dotfiles/tmux/tmux.conf;

  # nvim writes nvim-pack-lock.json into ~/.config/nvim/, so we
  # symlink individual files rather than the directory itself.
  xdg.configFile."nvim/init.lua".source = ./dotfiles/nvim/init.lua;
  xdg.configFile."nvim/lua".source      = ./dotfiles/nvim/lua;
  xdg.configFile."nvim/lsp".source      = ./dotfiles/nvim/lsp;

  # opencode: system theme for transparent terminal background.
  xdg.configFile."opencode/tui.json".text = ''
    {
      "$schema": "https://opencode.ai/tui.json",
      "theme": "system"
    }
  '';

  # bash is managed by home-manager (instead of NixOS's programs.bash)
  # so that programs.bash.enable = true sources hm-session-vars.sh.
  # `initExtra` is appended to the generated .bashrc but only runs in
  # interactive shells (the generated .bashrc early-returns otherwise),
  # matching the original NixOS programs.bash.interactiveShellInit semantics.
  programs.bash = {
    enable = true;
    initExtra =
      ''
        eval "$(${pkgs.direnv}/bin/direnv hook bash)"
      ''
      + builtins.readFile ./dotfiles/.bashrc;
  };
}
