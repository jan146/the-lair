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
  };
  config = {
    username = "jan";
    hostname = "venice";
    domainName = "kmet.dev";
  };
}
