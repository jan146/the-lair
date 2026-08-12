{ config, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  virtualisation.oci-containers.containers.feishin = {
    image = "ghcr.io/jeffvli/feishin:latest";
    environment = {
      SERVER_URL = "https://navidrome.${config.domainName}";
      SERVER_NAME = "navidrome";
      SERVER_TYPE = "navidrome";
      REMOTE_URL = "https://navidrome.${config.domainName}";
      ANALYTICS_DISABLED = "true";
    };
    ports = [
      "9180:9180"
    ];
  };
  services.nginx = {
    virtualHosts."feishin.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "music.${config.domainName}" ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:9180";
      };
    };
  };
}
