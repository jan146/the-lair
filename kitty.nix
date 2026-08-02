{ config, pkgs, hjem, ... }:
{
  environment.systemPackages = with pkgs; [
    kitty
  ];  
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
  ];
  hjem.users."${config.username}".files = {
    ".config/kitty/kitty.conf".source = config.dotfiles + "/.config/kitty/kitty.conf";
  };
}
