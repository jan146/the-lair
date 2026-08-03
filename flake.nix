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
  };
  outputs = inputs@{ self, nixpkgs, hjem, dotfiles }: {
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
