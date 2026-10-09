{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fastfetch
    tree
    htop
    btop
    pwgen
    killall
    diskonaut-ng
    file
    pciutils
    usbutils
  ];
}
