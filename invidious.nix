{ config, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
  fqdn = "invidious.${config.domainName}";
in
{
  age.secrets.basicAuth = {
    file = ./secrets/invidiousBasicAuth.age;
    owner = config.services.nginx.user;
    group = config.services.nginx.group;
  };
  services.invidious = {
    enable = true;
    domain = fqdn;
    port = 3001;
    nginx.enable = true;
    http3-ytproxy.enable = true;
    database.createLocally = true;
    settings = {
      registration_enabled = true;
      login_enabled = true;
      use_innertube_for_captions = true;
      default_user_preferences.autoplay = false;
      admins = [ "admin" config.username ];
      # invidious_companion.private_url = "http://127.0.0.1:8282";
    };
  };
  # services.postgresql.settings.port = config.services.invidious.database.port;
  services.nginx.virtualHosts."${fqdn}" = withBlocklist {
    locations."/" = {
      extraConfig = ''
        auth_basic    "Invidious login";
        auth_basic_user_file  ${config.age.secrets.basicAuth.path};
      '';
    };
  };
}
