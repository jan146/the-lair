{ config, pkgs, lib, ... }:
let
  mediaGroup = "media";
  jellyfinDir = "${config.mediaDir}/jellyfin";
  sonarrDir = "${config.mediaDir}/sonarr";
  radarrDir = "${config.mediaDir}/radarr";
  lidarr = "${config.mediaDir}/lidarr";
  jackettDir = "${config.mediaDir}/jackett";
  bazarrDir = "${config.mediaDir}/bazarr";
  seerrDir = "${config.mediaDir}/seerr";
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  # Media group for accessing mediaDir (TODO: cleaner solution)
  users.groups."${mediaGroup}".members = [
    "jellyfin"
    "radarr"
    "sonarr"
    "lidarr"
    "jackett"
    "bazarr"
    "seerr"
    "${config.username}"
  ];
  services.qbittorrent.group = mediaGroup;

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    # Packages for handling music media
    shntool
    flac
  ];

  # Jellyfin
  services.jellyfin = {
    enable = true;
    cacheDir = "${jellyfinDir}/cache";
    configDir = "${jellyfinDir}/config";
    dataDir = "${jellyfinDir}/data";
    logDir = "${jellyfinDir}/log";
  };
  services.nginx = {
    virtualHosts."jellyfin.${config.domainName}" = withBlocklist {
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
    virtualHosts."sonarr.${config.domainName}" = withBlocklist {
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
    virtualHosts."radarr.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
      };
    };
  };

  # Lidarr
  services.lidarr = {
    enable = true;
    dataDir = "${lidarr}/data";
    settings.log.analyticsEnabled = false;
  };
  services.nginx = {
    virtualHosts."lidarr.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8686";
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
    virtualHosts."jackett.${config.domainName}" = withBlocklist {
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
    virtualHosts."bazarr.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:6767";
      };
    };
  };

  # Seerr
  services.seerr = {
    enable = true;
    configDir = "${seerrDir}/config";
  };
  users.users."seerr" = {
    isSystemUser = true;
    group = "seerr";
  };
  users.groups."seerr" = {};
  systemd.services.seerr.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "seerr";
    Group = "media";
    ReadWritePaths = [ seerrDir ];
  };
  services.nginx = {
    virtualHosts."seerr.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5055";
      };
    };
  };
}
