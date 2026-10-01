{ config, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  age.secrets.dailytxtEnv = {
    file = ./secrets/dailytxtEnv.age;
    owner = "dailytxt";
    group = "dailytxt";
  };
  virtualisation.quadlet.networks.dailytxt = {
    networkConfig.internal = true;
    rootlessConfig.uid = config.users.users.dailytxt.uid;
  };
  users.groups.dailytxt = {};
  users.users.dailytxt = {
    isSystemUser = true;
    group = "dailytxt";
    home = "/var/lib/dailytxt";
    createHome = true;
    linger = true;
    useDefaultShell = true;
    uid = 974;
    autoSubUidGidRange = true;
  };
  virtualisation.oci-containers.containers = {
    dailytxt = {
      image = "phitux/dailytxt:2.6.3";
      environment = {
        ALLOW_REGISTRATION = "true";
        LOGOUT_AFTER_DAYS = "1";
      };
      environmentFiles = [
        # ADMIN_PASSWORD, SECRET_TOKEN (openssl rand -base64 32)
        config.age.secrets.dailytxtEnv.path
      ];
      ports = [
        "8000:80"
      ];
      volumes = [
        "dailytxt:/data"
      ];
      podman.user = "dailytxt";
      extraOptions = [
        "--network=dailytxt"
      ];
    };
  };
  services.nginx = {
    virtualHosts."dailytxt.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000";
      };
    };
  };
}
