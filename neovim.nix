{ config, pkgs, hjem, ... }:
let
  nvim = builtins.fetchGit {
    url = "https://github.com/jan146/nvim";
    rev = "d0789be7ba21e9987b2e1021964111221640f111";
  };
  packer = builtins.fetchGit {
    url = "https://github.com/wbthomason/packer.nvim";
    rev = "ea0cc3c59f67c440c5ff0bbe4fb9420f4350b9a3";
  };
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
    ".config/nvim".source = nvim;
    ".local/share/nvim/site/pack/packer/start/packer.nvim".source = packer;
  };
  hjem.users.root.files = {
    ".config/nvim".source = nvim;
    ".local/share/nvim".source = homeDir + "/.local/share/nvim";
  };
}
