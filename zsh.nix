{ config, pkgs, hjem, inputs, ... }:
let
  dotfileSymlinks = {
    # ".zshrc".source = inputs.dotfiles + "/.zshrc";
    # ".p10k.zsh".source = inputs.dotfiles + "/.p10k.zsh";
    ".aliasrc".source = inputs.dotfiles + "/.aliasrc";
    ".toolsrc".source = inputs.dotfiles + "/.toolsrc";
  };
  homeDir = config.users.users."${config.username}".home;
in
{
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [
      "git"
      "python"
      "man"
    ];
    # theme = "agnoster";
  };
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    histSize = 100000;
    syntaxHighlighting.enable = true;
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ~/.aliasrc
      source ~/.toolsrc
    '';
  };
  environment.systemPackages = with pkgs; [
    zsh
    zsh-powerlevel10k
  ];
  users.defaultUserShell = pkgs.zsh;
  hjem.users."${config.username}".files = dotfileSymlinks;
  hjem.users.root.files = dotfileSymlinks // {
    ".zshrc".source = homeDir + "/.zshrc";
    ".p10k.zsh".source = homeDir + "/.p10k.zsh";
  };
}
