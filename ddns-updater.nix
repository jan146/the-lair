{ config, lib, ... }:
{
  # Lowercase filename because ddns-updater converts to lowercase for some reason ...
  age.secrets.ddnsupdaterconfig = {
    file = ./secrets/ddnsUpdaterConfig.age;
    owner = "root";
    group = "root";
  };
  services.ddns-updater = {
    enable = true;
    environment = {
      SERVER_ENABLED="no";
      # Warning: file below contains domain name (in case you need to update it)
      CONFIG_FILEPATH = config.age.secrets.ddnsupdaterconfig.path;
      PERIOD = "5m";
      HTTP_TIMEOUT = "60s";
    };
  };
  systemd.services.ddns-updater.serviceConfig = {
    DynamicUser = lib.mkForce false;
  };
}
