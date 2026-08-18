{ config, pkgs, ... }:
let
  fqdn = "nextcloud.${config.domainName}";
  withBlocklist = import ./nginx-blocklist.nix;
  domainAliases = [ "files.${config.domainName}" ];
in
{
  age.secrets.adminPass = {
    file = ./secrets/nextcloudPass.age;
    owner = "root";
    group = "root";
  };
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud34;
    hostName = fqdn;
    https = true;
    config = {
      adminuser = "admin";
      adminpassFile = config.age.secrets.adminPass.path;
      dbtype = "sqlite";
    };
    # config.dbtype = "pgsql";
    settings.trusted_domains = ([ config.domainName fqdn ] ++ domainAliases);
  };
  services.nginx.virtualHosts."${fqdn}" = withBlocklist {
    enableACME = true;
    forceSSL = true;
    serverAliases = domainAliases;
  };
}
