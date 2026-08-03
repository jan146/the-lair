{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
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
  };
  outputs = inputs@{ self, nixpkgs, hjem, nix-index-database, agenix, ... }: {
    nixosConfigurations.venice = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        inputs.hjem.nixosModules.default
        nix-index-database.nixosModules.default
        # optional to also wrap and install comma
        # { programs.nix-index-database.comma.enable = true; }
        agenix.nixosModules.default
      ];
    };
  };
}
