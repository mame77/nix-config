{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, llm-agents, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./tmux.nix
        ./bashrc.nix
        ./nvim.nix

        ({ pkgs, ... }: {
          environment.systemPackages = with llm-agents.packages.${pkgs.system}; [
            opencode
	    grok
          ];
        })
      ];
    };
  };
}
