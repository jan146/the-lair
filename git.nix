{ config, pkgs, hjem, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
  ];
  hjem.users.${config.username}.files.".gitconfig".source = inputs.dotfiles + "/.gitconfig";
  hjem.users.root.files.".gitconfig".source = inputs.dotfiles + "/.gitconfig";
}
