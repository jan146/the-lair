{ config, pkgs, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
  version = "2.3.2243";
in
{
  age.secrets.suwayomiPass = {
    file = ../secrets/suwayomiPass.age;
    owner = config.services.suwayomi-server.user;
    group = config.services.suwayomi-server.group;
  };
  services.suwayomi-server = {
    enable = true;
    dataDir = "${config.hddDir}/suwayomi";
    settings.server = {
      ip = "127.0.0.1";
      port = 8081;
      basicAuthEnabled = true;
      basicAuthUsername = "admin";
      basicAuthPasswordFile = config.age.secrets.suwayomiPass.path;
      systemTrayEnabled = true;
      extensionRepos = [ "https://github.com/keiyoushi/extensions/raw/repo/index.pb" ];
    };
    package = pkgs.suwayomi-server.overrideAttrs (
      finalAttrs: previousAttrs: {version = version; src = builtins.fetchurl {
        url = previousAttrs.src.url;
        sha256 = "sha256:1mcdx50axdgb690mzzw34g97pw6qgrbyvpybsc14l38p5srl24c2";
      };}
    );
  };
  services.nginx.virtualHosts."suwayomi.${config.domainName}" = withBlocklist {
    enableACME = true;
    forceSSL = true;
    serverAliases = [ "comics.${config.domainName}" ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.suwayomi-server.settings.server.port}";
    };
  };
}
