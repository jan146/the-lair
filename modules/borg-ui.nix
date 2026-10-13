{ config, lib, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
  # borgJobs = config.services.borgbackup.jobs;
  # borgPaths = (
  #   map (path: builtins.replaceStrings ["/./"] ["/"] path)
  #   (lib.lists.flatten (
  #     lib.attrsets.mapAttrsToList (name: value: value.paths) borgJobs
  #   ))
  # );
  # borgVolumes = map (path: "${path}:/host${path}:ro") borgPaths;
in
{
  virtualisation.oci-containers.containers = {
    borg-ui = {
      image = "docker.io/ainullcode/borg-ui:latest";
      environment = {
        # APP_URL = "http://localhost:3000";
        # REDIS_URL = "redis://redis:6379";
      };
      environmentFiles = [
        # APP_SECRET and DATABASE_URL
        # config.age.secrets.docmostEnv.path
      ];
      ports = [
        "8082:8081"
      ];
      volumes = [
        "borg_data:/data"
        "borg_cache:/home/borg/.cache/borg"
      ];
    };
  };
  services.nginx.virtualHosts."borg.${config.domainName}" = withBlocklist {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8082";
    };
  };
}
