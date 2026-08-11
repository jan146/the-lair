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
  age.secrets.invidiousExtraSettings = {
    file = ./secrets/invidiousExtraSettings.age;
    owner = "invidious";
    group = "invidious";
  };
  age.secrets.invidiousCompanionEnv = {
    file = ./secrets/invidiousCompanionEnv.age;
    owner = "invidious";
    group = "invidious";
  };

  users.users.invidious = {
    isSystemUser = true;
    group = "invidious";
  };
  users.groups.invidious = {};

  services.invidious = {
    enable = true;
    domain = fqdn;
    port = 3001;
    nginx.enable = true;
    http3-ytproxy.enable = true;
    database.createLocally = true;
    extraSettingsFile = config.age.secrets.invidiousExtraSettings.path;
    settings = {
      registration_enabled = true;
      login_enabled = true;
      use_innertube_for_captions = true;
      default_user_preferences.autoplay = false;
      admins = [ "admin" config.username ];
      invidious_companion = [
        {
          private_url = "http://127.0.0.1:8282/companion";
          public_url = "https://${fqdn}/companion";
        }
      ];
    };
  };

  # Invidious companion
  virtualisation.oci-containers.containers.invidious-companion = {
    image = "quay.io/invidious/invidious-companion:latest";
    ports = [
      "8282:8282"
    ];
    environmentFiles = [
      config.age.secrets.invidiousCompanionEnv.path
    ];
    volumes = [
      "companioncache:/var/tmp/youtubei.js:rw"
    ];
    extraOptions = [
      "--security-opt=no-new-privileges:true"
    ];
  };

  services.nginx.virtualHosts."${fqdn}" = withBlocklist {
    locations."/companion" = {
      proxyPass = "http://127.0.0.1:8282";
    };
    locations."/" = {
      extraConfig = ''
        auth_basic    "Invidious login";
        auth_basic_user_file  ${config.age.secrets.basicAuth.path};
      '';
    };
  };
}
