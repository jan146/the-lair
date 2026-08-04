{ config, ... }:
let
  user = config.username;
  modifyConfig = contConf: contConf // {
    podman.user = user;
    autoStart = true;
    privileged = false;
    extraOptions = [
      "--network=host"
    ];
  };
in
{
  age.secrets.docmostEnv = {
    file = ./secrets/docmostEnv.age;
    owner = user;
    group = "users";
  };
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    docmost = modifyConfig {
      image = "docker.io/docmost/docmost:latest";
      dependsOn = [ "db" "redis" ];
      environment = {
        APP_URL = "http://localhost:3000";
        REDIS_URL = "redis://localhost:6379";
      };
      environmentFiles = [
        # APP_SECRET and DATABASE_URL
        config.age.secrets.docmostEnv.path
      ];
      ports = [
        "127.0.0.1:3000:3000"
      ];
      volumes = [
        "docmost:/app/data/storage"
      ];
    };

    db = modifyConfig {
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

    redis = modifyConfig {
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
    virtualHosts."docmost.${config.domainName}" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };
}
