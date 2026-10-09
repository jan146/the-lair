{ config, inputs, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
  mv = inputs.multiverse.multiverse.x86_64-linux;
  pkgs_26_05 = mv.at "26.05";
in
{
  services.navidrome = {
    enable = true;
    group = "media";
    settings = {
      MusicFolder = "${config.mediaDir}/music";
      Address = "0.0.0.0";
    };
    plugins = [ pkgs_26_05.navidromePlugins.discord-rich-presence ];
  };
  systemd.services.navidrome.serviceConfig.Environment = "ND_BASEURL=https://navidrome.${config.domainName}";
  services.nginx = {
    virtualHosts."navidrome.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4533";
      };
    };
  };
}
