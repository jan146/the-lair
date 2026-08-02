{ config, pkgs, hjem, ... }:
{
  environment.systemPackages = with pkgs; [
    git
  ];
  hjem.users.${config.username}.files.".gitconfig".source = config.dotfiles + "/.gitconfig";
  hjem.users.root.files.".gitconfig".source = config.dotfiles + "/.gitconfig";
}
