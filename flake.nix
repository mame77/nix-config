{
  description = "My NixOS Configuration";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.systems.follows = "systems";
    };
    systems = {
      url = "path:./systems.nix";
      flake = false;
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    handy = {
      url = "github:cjpais/Handy";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.bun2nix.inputs.systems.follows = "systems";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      mkHost = path: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          path
          home-manager.nixosModules.home-manager
          ({ ... }: {
            nixpkgs.config.allowUnfreePredicate = pkg:
              builtins.elem (nixpkgs.lib.getName pkg) [ "vivaldi" "obsidian" ];
            nixpkgs.config.allowDeprecatedx86_64Darwin = true;
            # Propagate `inputs` to home-manager modules (noctalia, etc.).
            home-manager.extraSpecialArgs = { inherit inputs; };
          })
        ];
      };
    in {
      packages.x86_64-linux = {
        karukan-dict = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/karukan-dict.nix {};
        karukan-models = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/karukan-models.nix {};
        fcitx5-karukan = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/fcitx5-karukan.nix {};
      };

      nixosConfigurations.laptop = mkHost ./hosts/laptop;
      nixosConfigurations.server = mkHost ./hosts/server;
    };
}
