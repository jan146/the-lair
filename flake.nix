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
  };
  outputs = inputs@{ self, nixpkgs, hjem, ... }: {
    nixosConfigurations.venice = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        inputs.hjem.nixosModules.default
      ];
    };
  };
}
