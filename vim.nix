{ config, pkgs, hjem, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
  ];
  hjem.users.${config.username}.files.".vimrc".source = inputs.dotfiles + "/.vimrc";
  hjem.users.root.files.".vimrc".source = inputs.dotfiles + "/.vimrc";
}
