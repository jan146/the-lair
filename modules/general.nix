{ pkgs, inputs, ... }:
let
  mv = inputs.multiverse.multiverse.x86_64-linux;
  pkgs_unstable = mv.tip;
in
{
  environment.systemPackages = with pkgs; [
    fastfetch
    tree
    htop
    btop
    pwgen
    killall
    pkgs_unstable.diskonaut-ng
    file
  ];
}
