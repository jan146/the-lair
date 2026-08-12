{ config, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  age.secrets.homarrEnv = {
    file = ./secrets/homarrEnv.age;
    owner = config.username;
    group = "users";
  };
  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/homarr-labs/homarr:latest";
    autoStart = true;
    ports = [
      "127.0.0.1:7575:7575"
    ];
    volumes = [
      "homarr-appdata:/appdata"
    ];
    environmentFiles = [
      # SECRET_ENCRYPTION_KEY
      config.age.secrets.homarrEnv.path
    ];
  };
  services.nginx = {
    virtualHosts."homarr.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "home.${config.domainName}" ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:7575";
        proxyWebsockets = true;
      };
    };
  };
}
