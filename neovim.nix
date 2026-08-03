{ config, pkgs, hjem, inputs, ... }:
let
  homeDir = config.users.users."${config.username}".home;
in
{
  environment.systemPackages = with pkgs; [
    neovim
	ripgrep
	unzip
	nodejs
	python3
  ];
  hjem.users.${config.username}.files = {
    ".config/nvim".source = inputs.nvim;
    ".local/share/nvim/site/pack/packer/start/packer.nvim".source = inputs.packer;
  };
  hjem.users.root.files = {
    ".config/nvim".source = inputs.nvim;
    ".local/share/nvim".source = homeDir + "/.local/share/nvim";
  };
}
