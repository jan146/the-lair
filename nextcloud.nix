{ config, pkgs, ... }:
let
  fqdn = "nextcloud.${config.domainName}";
  withBlocklist = import ./nginx-blocklist.nix;
  domainAliases = [ "files.${config.domainName}" ];
  dataDir = config.hddDir + "/nextcloud";
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
    database.createLocally = true;
    datadir = dataDir;
    config = {
      adminuser = "admin";
      adminpassFile = config.age.secrets.adminPass.path;
      dbtype = "sqlite";
      # dbtype = "pgsql";
      # dbname = "nextcloud";
      # dbuser = "nextcloud";
    };
    settings.trusted_domains = ([ config.domainName fqdn ] ++ domainAliases);
  };
  systemd.tmpfiles.rules = [ "d ${dataDir} 0700 nextcloud nextcloud -" ];
  # services.postgresql.ensureUsers = [ { name = "nextcloud"; } ];
  # services.postgresql.ensureDatabases = [ "nextcloud" ];
  services.nginx.virtualHosts."${fqdn}" = withBlocklist {
    enableACME = true;
    forceSSL = true;
    serverAliases = domainAliases;
  };
  environment.systemPackages = with pkgs; [
    nextcloud34
  ];
}
