{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "github:jan146/dotfiles";
      flake = false;
    };
    nvim = {
      url = "github:jan146/nvim";
      flake = false;
    };
    packer = {
      url = "github:wbthomason/packer.nvim";
      flake = false;
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      # optional, not necessary for the module
      inputs.nixpkgs.follows = "nixpkgs";
      # optionally choose not to download darwin deps (saves some resources on Linux)
      inputs.darwin.follows = "";
    };
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
  };
  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, hjem, nix-index-database, agenix, multiverse, quadlet-nix, ... }:
    let
      mkHost = hostName: nixpkgs: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostName}/configuration.nix
          hjem.nixosModules.default
          nix-index-database.nixosModules.default
          # optional to also wrap and install comma
          # { programs.nix-index-database.comma.enable = true; }
          agenix.nixosModules.default
          quadlet-nix.nixosModules.quadlet
        ];
      };
    in
    {
    nixosConfigurations = {
      venice = mkHost "venice" nixpkgs;
      caracas = mkHost "caracas" nixpkgs-unstable;
    };
  };
}
