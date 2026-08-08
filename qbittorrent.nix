{ config, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  services.qbittorrent = {
    enable = true;
    profileDir = "${config.mediaDir}/qbittorrent/profile";
    serverConfig = {
      LegalNotice.Accepted = true;
      Meta.MigrationVersion = 8; # Needed for RemoveWithContent
      Preferences.WebUI.Password_PBKDF2 = "@ByteArray(ou4uZSDmppbJ0o1V/XESQg==:3H8X1MqU9Lnz6WjSHej+EgoPdY2cY2myQiObvhD6N/v80/FDD8z1tNNuNgHUlmDFNxftDDTBUGwMlOcF1q9GAg==)";
      BitTorrent.Session = {
        GlobalUPSpeedLimit = (80 * 1000 / 8); # 80 Mb = 10,000 KB
        GlobalDLSpeedLimit = (500 * 1000 / 8);  # 500 Mb = 62,500 KB
        GlobalMaxSeedingMinutes = 1440;
        ShareLimitAction = "Stop";
        AddTrackersFromURLEnabled = true;
        AdditionalTrackersURL = "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt";
      };
    };
  };
  services.nginx = {
    virtualHosts."qbittorrent.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        extraConfig =
          "proxy_set_header   Host               $proxy_host;" +
          "proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;" +
          "proxy_set_header   X-Forwarded-Host   $http_host;" +
          "proxy_set_header   X-Forwarded-Proto  $scheme;";
      };
    };
  };
}
