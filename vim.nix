{ config, pkgs, hjem, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
  ];
  hjem.users.${config.username}.files.".vimrc".source = config.dotfiles + "/.vimrc";
  hjem.users.root.files.".vimrc".source = config.dotfiles + "/.vimrc";
}
