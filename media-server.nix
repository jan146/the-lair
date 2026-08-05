{ config, pkgs, ... }:
let
  mediaGroup = "media";
  jellyfinDir = "${config.mediaDir}/jellyfin";
  sonarrDir = "${config.mediaDir}/sonarr";
  radarrDir = "${config.mediaDir}/radarr";
in
{
  # Media group for accessing mediaDir (TODO: cleaner solution)
  users.groups."${mediaGroup}".members = [
    "jellyfin"
    "radarr"
    "sonarr"
    "${config.username}"
  ];

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

  # Sonarr
  services.sonarr = {
    enable = true;
    dataDir = "${sonarrDir}/data";
    settings.log.analyticsEnabled = false;
  };
  services.nginx = {
    virtualHosts."sonarr.${config.domainName}" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8989";
      };
    };
  };

  # Radarr
  services.radarr = {
    enable = true;
    dataDir = "${radarrDir}/data";
    settings.log.analyticsEnabled = false;
  };
  services.nginx = {
    virtualHosts."radarr.${config.domainName}" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
      };
    };
  };
}
