{ config, ... }:
let
  dataDir = config.hddDir + "/postgres";
in
{
  services.postgresql = {
    enable = true;
    dataDir = dataDir;
  };
  systemd.tmpfiles.rules = [ "d ${dataDir} 0700 postgres postgres -" ];
}
