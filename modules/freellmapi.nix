{ config, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  age.secrets.freellmapiEnv = {
    file = ../secrets/freellmapiEnv.age;
    owner = "freellmapi";
    group = "freellmapi";
  };
  users.groups.freellmapi = {};
  users.users.freellmapi = {
    isSystemUser = true;
    group = "freellmapi";
    home = "/var/lib/freellmapi";
    createHome = true;
    linger = true;
    useDefaultShell = true;
    uid = 975;
    autoSubUidGidRange = true;
  };
  virtualisation.oci-containers.containers = {
    freellmapi = {
      image = "ghcr.io/tashfeenahmed/freellmapi";
      podman.user = "freellmapi";
      environment = {
        NODE_ENV = "production";
        PORT = "3004";
      };
      environmentFiles = [
        # ENCRYPTION_KEY="$(openssl rand -hex 32)"
        config.age.secrets.freellmapiEnv.path
      ];
      ports = [
        "3004:3004"
      ];
      volumes = [
        "freellmapi-data:/app/server/data"
      ];
    };
  };
  services.nginx = {
    virtualHosts."freellmapi.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3004";
      };
    };
  };
}
