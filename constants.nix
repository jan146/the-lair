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
    dotfiles = mkOption {
      type = types.path;
    };
  };
  config = {
    username = "jan";
    hostname = "venice";
    domainName = "kmet.dev";
    dotfiles = builtins.fetchGit {
      url = "https://github.com/jan146/dotfiles";
      rev = "e68564b464a35acc33b70d8cc66679d187bf042f";
    };
  };
}
