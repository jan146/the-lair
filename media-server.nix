{ config, pkgs, ... }:
let
  mediaGroup = "media";
  jellyfinDir = "${config.mediaDir}/jellyfin";
  sonarrDir = "${config.mediaDir}/sonarr";
  radarrDir = "${config.mediaDir}/radarr";
  jackettDir = "${config.mediaDir}/jackett";
  bazarrDir = "${config.mediaDir}/bazarr";
in
{
  # Media group for accessing mediaDir (TODO: cleaner solution)
  users.groups."${mediaGroup}".members = [
    "jellyfin"
    "radarr"
    "sonarr"
    "jackett"
    "bazarr"
    "${config.username}"
  ];
  services.qbittorrent.group = mediaGroup;

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

  # Jackett
  services.jackett = {
    enable = true;
    dataDir = "${jackettDir}/data";
  };
  services.flaresolverr.enable = true; # Bypass Cloudflare (eyeroll)
  services.nginx = {
    virtualHosts."jackett.${config.domainName}" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9117";
      };
    };
  };

  # Bazarr
  services.bazarr = {
    enable = true;
    dataDir = "${bazarrDir}/data";
  };
  services.nginx = {
    virtualHosts."bazarr.${config.domainName}" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:6767";
      };
    };
  };
}
