{ config, lib, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
  fqdn = "searxng.${config.domainName}";
  categoryToEngines = rec {
    privacy = [
      "duckduckgo"
      "startpage"
      "brave"
      "qwant"
    ];
    broad = privacy ++ [
      "google"
      "bing"
      "yahoo"
      "wikipedia"
    ];
    global = broad ++ [
      "yandex"
      "baidu"
    ];
  };
  makeEngine = engine: 
    let
      isDefault = builtins.elem engine categoryToEngines.privacy;
    in
  {
    name = engine;
    categories = (if isDefault then ["general"] else []) ++ builtins.filter
      (category: builtins.elem engine categoryToEngines.${category})
      (builtins.attrNames categoryToEngines);
    disabled = !(isDefault);
  };
  makeEngines = engines: map makeEngine engines;
  allEngines = lib.lists.unique (
    builtins.concatLists (builtins.attrValues categoryToEngines)
  );
  engines = makeEngines allEngines;
in
{
  age.secrets.searxngEnv = {
    file = ./secrets/searxngEnv.age;
    owner = "root";
    group = "root";
  };
  age.secrets.searxngBasicAuth = {
    file = ./secrets/searxngBasicAuth.age;
    owner = config.services.nginx.user;
    group = config.services.nginx.group;
  };
  services.searx = {
    enable = false;
    settings = {
      server = {
        base_url = "https://${fqdn}";
        bind_address = "0.0.0.0";
        port = 8888;
        secret_key = "$SEARXNG_SECRET";
      };
      general = {
        enable_metrics = false;
      };
      search = {
        safe_search = 0;
        autocomplete = "duckduckgo";
      };
      ui = {
        results_on_new_tab = false;
      };
      engines = engines;
    };
    environmentFile = config.age.secrets.searxngEnv.path;
  };
  services.nginx = {
    virtualHosts."${fqdn}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "search.${config.domainName}" ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:8888";
        extraConfig = ''
          auth_basic    "SearXNG login";
          auth_basic_user_file  ${config.age.secrets.searxngBasicAuth.path};
        '';
      };
    };
  };
}
