{ config, ... }:
let
  dataDir = config.hddDir + "/postgres";
in
{
  services.postgresql = {
    enable = false;
    dataDir = dataDir;
  };
}
