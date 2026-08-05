{ lib, ... }:
{
  options = with lib; {
    username = mkOption {
      type = types.str;
    };
    hostname = mkOption {
      type = types.str;
    };
    domainName = mkOption {
      type = types.str;
    };
    hddDir = mkOption {
      type = types.str;
    };
    mediaDir = mkOption {
      type = types.str;
    };
  };
  config = rec {
    username = "jan";
    hostname = "venice";
    domainName = "kmet.dev";
    hddDir = "/mnt/hdd";
    mediaDir = "${hddDir}/media";
  };
}
