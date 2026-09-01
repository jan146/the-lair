{ config, ... }:
let
  dataDir = config.hddDir + "/postgres";
in
{
  services.postgresql = {
    enable = true;
    dataDir = dataDir;
  };
}
