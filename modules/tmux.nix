{ config, pkgs, hjem, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    tmux
  ];
  hjem.users.${config.username}.files.".tmux.conf".source = inputs.dotfiles + "/.tmux.conf";
  hjem.users.root.files.".tmux.conf".source = inputs.dotfiles + "/.tmux.conf";
}
