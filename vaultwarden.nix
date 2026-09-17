{ config, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  age.secrets.vaultwardenEnv = {
    file = ./secrets/vaultwardenEnv.age;
  };
  services.vaultwarden = {
    enable = true;
    backupDir = "${config.hddDir}/vaultwarden";
    # Uncomment and go to /admin to create admin user
    # environmentFile = config.age.secrets.vaultwardenEnv.path;
    config = {
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };
  services.nginx.virtualHosts."vaultwarden.${config.domainName}" = withBlocklist {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
      proxyWebsockets = true;
    };
  };
}
