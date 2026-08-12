# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./constants.nix
      ./bootloader.nix
      ./users-and-groups.nix
      ./networking.nix
      ./audio.nix
      ./locale.nix
      ./desktop.nix
      ./openssh.nix
      ./ddns-updater.nix
      ./agenix.nix
      ./sudo.nix
      ./git.nix
      ./zsh.nix
      ./tmux.nix
      ./vim.nix
      ./neovim.nix
      ./podman.nix
      ./kitty.nix
      ./hjem.nix
      ./acme.nix
      ./nginx.nix
      ./murmur.nix
      ./docmost.nix
      ./media-server.nix
      ./qbittorrent.nix
      ./homarr.nix
      ./fmhy.nix
      ./navidrome.nix
      ./invidious.nix
      ./feishin.nix
    ];

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    fastfetch
    tree
    htop
    btop
    pwgen
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
