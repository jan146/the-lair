{ config, pkgs, ... }:
let
  # https://discourse.nixos.org/t/getting-kde-plasma-bigscreen-to-work-on-nixos/79086
  overlayPlasmaBigscreen = (final: prev: {
    kdePackages = prev.kdePackages // {
      plasma-bigscreen = prev.kdePackages.plasma-bigscreen.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ prev.kdePackages.kdeconnect-kde ];
        preFixup = ''
          wrapQtApp $out/bin/plasma-bigscreen-wayland \
            --prefix QML2_IMPORT_PATH : "${prev.kdePackages.kdeconnect-kde}/lib/qt-6/qml"
        '';
      });
    };
  });
in
{
  nixpkgs.overlays = [ overlayPlasmaBigscreen ];
  programs.kdeconnect.enable = true;
  environment.systemPackages = [
    pkgs.kdePackages.plasma-bigscreen
    pkgs.kdePackages.plasma-desktop
  ];
  xdg.portal.configPackages = [ pkgs.kdePackages.plasma-bigscreen ];
  services.displayManager = {
    defaultSession = "plasma-bigscreen-wayland";
    sessionPackages = [ pkgs.kdePackages.plasma-bigscreen ];
    sddm = {
      enable = true;
      wayland.enable = true;
      enableHidpi = true;
      settings = {
        Autologin = {
          Session = "plasma-bigscreen-wayland.desktop";
          User = config.username;
        };
      };
    };
  };
}
