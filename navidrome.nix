{ config, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  services.navidrome = {
    enable = true;
    group = "media";
    settings = {
      MusicFolder = "${config.mediaDir}/music";
      Address = "0.0.0.0";
    };
  };
  services.nginx = {
    virtualHosts."navidrome.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4533";
      };
    };
  };
}
