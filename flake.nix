{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      mkHost = path: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ path ];
      };
    in {
      nixosConfigurations.laptop = mkHost ./hosts/laptop;
      nixosConfigurations.server = mkHost ./hosts/server;
      nixosConfigurations.nixos = mkHost ./hosts/server;
    };
}
