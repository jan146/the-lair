{ config, pkgs, hjem, inputs, ... }:
{
  programs.vim.enable = true;
  programs.vim.defaultEditor = true;
  environment.systemPackages = with pkgs; [
    vim
  ];
  hjem.users.${config.username}.files.".vimrc".source = inputs.dotfiles + "/.vimrc";
  hjem.users.root.files.".vimrc".source = inputs.dotfiles + "/.vimrc";
}
