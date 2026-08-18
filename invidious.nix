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
  age.secrets.invidiousPgPass = {
    file = ./secrets/invidiousPgPass.age;
    owner = "invidious";
    group = "invidious";
  };
  age.secrets.invidiousEnv = {
    file = ./secrets/invidiousEnv.age;
    owner = "invidious";
    group = "invidious";
  };
  age.secrets.invidiousExtraSettings = {
    file = ./secrets/invidiousExtraSettings.age;
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
    database = {
      createLocally = false;
      host = "localhost";
      port = 5434;
      passwordFile = config.age.secrets.invidiousPgPass.path;
    };
    extraSettingsFile = config.age.secrets.invidiousExtraSettings.path;
    settings = {
      registration_enabled = false;
      login_enabled = true;
      popular_enabled = false;
      statistics_enabled = false;
      use_innertube_for_captions = true;
      default_user_preferences = {
        autoplay = false;
        feed_menu = ["Trending" "Subscriptions" "Playlists"];
        default_home = "Trending";
      };
      admins = [ "admin" config.username ];
      invidious_companion = [
        {
          private_url = "http://127.0.0.1:8282/companion";
          public_url = "https://${fqdn}/companion";
        }
      ];
    };
  };

  # Postgres DB
  virtualisation.oci-containers.containers = {
    invidious-pg = {
      image = "docker.io/library/postgres:18";
      environment = {
        POSTGRES_DB = "invidious";
        POSTGRES_USER = "invidious";
      };
      ports = [
        "5434:5432"
      ];
      environmentFiles = [
        # POSTGRES_PASSWORD
        config.age.secrets.invidiousEnv.path
      ];
      volumes = [
        "invidious-pg:/var/lib/postgresql"
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
      # SERVER_SECRET_KEY
      config.age.secrets.invidiousEnv.path
    ];
    volumes = [
      "companioncache:/var/tmp/youtubei.js:rw"
    ];
    extraOptions = [
      "--security-opt=no-new-privileges:true"
    ];
  };

  services.nginx.virtualHosts."${fqdn}" = withBlocklist {
    serverAliases = [ "youtube.${config.domainName}" ];
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
