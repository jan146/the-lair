{ config, pkgs, ... }:
let
  mediaDir = "${config.hddDir}/media";
  jellyfinDir = "${mediaDir}/jellyfin";
in
{
  # Media group for accessing mediaDir (TODO: cleaner solution)
  users.groups.media = {};
  users.users = {
    jellyfin.extraGroups = [ "media" ];
    "${config.username}".extraGroups = [ "media" ];
  };

  # Jellyfin
  services.jellyfin = {
    enable = true;
    cacheDir = "${jellyfinDir}/cache";
    configDir = "${jellyfinDir}/config";
    dataDir = "${jellyfinDir}/data";
    logDir = "${jellyfinDir}/log";
  };
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
  services.nginx = {
    virtualHosts."jellyfin.${config.domainName}" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
      };
    };
  };
}
