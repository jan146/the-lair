# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, inputs, ... }:
let
  mv = inputs.multiverse.multiverse.x86_64-linux;
  pkgs_unstable = mv.tip;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./constants.nix
      ./bootloader.nix
      ./desktop.nix
      ../../modules/users-and-groups.nix
      ../../modules/networking.nix
      ../../modules/audio.nix
      ../../modules/locale.nix
      ../../modules/openssh.nix
      ../../modules/ddns-updater.nix
      ../../modules/agenix.nix
      ../../modules/sudo.nix
      ../../modules/git.nix
      ../../modules/zsh.nix
      ../../modules/tmux.nix
      ../../modules/vim.nix
      ../../modules/neovim.nix
      ../../modules/general.nix
      ../../modules/podman.nix
      ../../modules/kitty.nix
      ../../modules/hjem.nix
      ../../modules/acme.nix
      ../../modules/nginx.nix
      ../../modules/murmur.nix
      ../../modules/docmost.nix
      ../../modules/media-server.nix
      ../../modules/qbittorrent.nix
      ../../modules/homarr.nix
      ../../modules/fmhy.nix
      ../../modules/navidrome.nix
      ../../modules/invidious.nix
      ../../modules/feishin.nix
      ../../modules/wireguard.nix
      ../../modules/pi-hole.nix
      ../../modules/postgres.nix
      ../../modules/nextcloud.nix
      ../../modules/searxng.nix
      ../../modules/matrix.nix
      ../../modules/borg.nix
      ../../modules/vaultwarden.nix
      ../../modules/forgejo.nix
      ../../modules/suwayomi.nix
      # ../../modules/freellmapi.nix
      ../../modules/dailytxt.nix
    ];

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
