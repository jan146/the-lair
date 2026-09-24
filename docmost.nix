{ config, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
  defaultConfig = {
    podman.user = "docmost";
    extraOptions = [
      "--network=docmost"
    ];
  };
in
{
  age.secrets.docmostEnv = {
    file = ./secrets/docmostEnv.age;
    owner = "docmost";
    group = "docmost";
  };
  virtualisation.quadlet.networks.docmost = {
    networkConfig.internal = true;
    rootlessConfig.uid = config.users.users.docmost.uid;
  };
  users.groups.docmost = {};
  users.users.docmost = {
    isSystemUser = true;
    group = "docmost";
    home = "/var/lib/docmost";
    createHome = true;
    linger = true;
    useDefaultShell = true;
    uid = 976;
    autoSubUidGidRange = true;
  };
  virtualisation.oci-containers.containers = {
    docmost = defaultConfig // {
      image = "docker.io/docmost/docmost:latest";
      dependsOn = [ "db" "redis" ];
      environment = {
        APP_URL = "http://localhost:3000";
        REDIS_URL = "redis://redis:6379";
      };
      environmentFiles = [
        # APP_SECRET and DATABASE_URL
        config.age.secrets.docmostEnv.path
      ];
      ports = [
        "3000:3000"
      ];
      volumes = [
        "docmost:/app/data/storage"
      ];
    };

    db = defaultConfig // {
      image = "docker.io/library/postgres:18";
      environment = {
        POSTGRES_DB = "docmost";
        POSTGRES_USER = "docmost";
      };
      environmentFiles = [
        # POSTGRES_PASSWORD
        config.age.secrets.docmostEnv.path
      ];
      volumes = [
        "db_data:/var/lib/postgresql"
      ];
    };

    redis = defaultConfig // {
      image = "docker.io/library/redis:8";
      cmd = [
        "redis-server"
        "--appendonly"
        "yes"
        "--maxmemory-policy"
        "noeviction"
      ];
      volumes = [
        "redis_data:/data"
      ];
    };
  };
  services.nginx = {
    virtualHosts."docmost.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "docs.${config.domainName}" ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };
}
