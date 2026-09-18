{ config, ... }:
let
  fqdn = "forgejo.${config.domainName}";
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  services.forgejo = {
    enable = true;
    database.type = "postgres";
    # Enable support for Git Large File Storage
    lfs.enable = true;
    stateDir = "${config.hddDir}/forgejo";
    settings = {
      server = {
        DOMAIN = fqdn;
        # You need to specify this to remove the port from URLs in the web UI.
        ROOT_URL = "https://${fqdn}/";
        HTTP_PORT = 3003;
        SSH_PORT = 2222;
        START_SSH_SERVER = true;
      };
      # You can temporarily allow registration to create an admin user.
      service.DISABLE_REGISTRATION = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ config.services.forgejo.settings.server.SSH_PORT ];
  services.nginx.virtualHosts."${fqdn}" = withBlocklist {
    enableACME = true;
    forceSSL = true;
    serverAliases = [ "git.${config.domainName}" ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT}";
    };
  };
}
