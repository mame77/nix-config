{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      mkHost = path: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          path
          home-manager.nixosModules.home-manager
        ];
      };
    in {
      nixosConfigurations.laptop = mkHost ./hosts/laptop;
      nixosConfigurations.server = mkHost ./hosts/server;
      nixosConfigurations.nixos = mkHost ./hosts/server;
    };
}
