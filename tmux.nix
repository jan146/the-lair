{ config, pkgs, hjem, ... }:
{
  environment.systemPackages = with pkgs; [
    tmux
  ];
  hjem.users.${config.username}.files.".tmux.conf".source = config.dotfiles + "/.tmux.conf";
  hjem.users.root.files.".tmux.conf".source = config.dotfiles + "/.tmux.conf";
}
