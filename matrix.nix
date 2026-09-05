{ pkgs, config, ... }:
let
  fqdn = "matrix.${config.domainName}";
  baseUrl = "https://${fqdn}";
  clientConfig."m.homeserver".base_url = baseUrl;
  serverConfig."m.server" = "${fqdn}:443";
  mkWellKnown = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  services.nginx = {
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    virtualHosts = {
      "${config.domainName}" = withBlocklist {
        # enableACME = true;
        # forceSSL = true;
        locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
        locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
      };
      "${fqdn}" = withBlocklist {
        enableACME = true;
        forceSSL = true;
        locations."/".extraConfig = ''
          return 404;
        '';
        locations."/_matrix".proxyPass = "http://localhost:8008";
        locations."/_synapse/client".proxyPass = "http://localhost:8008";
      };
    };
  };

  age.secrets.matrixSharedSecret = {
    file = ./secrets/matrixSharedSecret.age;
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };
  services.matrix-synapse = {
    enable = true;
    dataDir = config.hddDir + "/matrix-synapse";
    extraConfigFiles = [ config.age.secrets.matrixSharedSecret.path ];
    settings = {
      server_name = config.domainName;
      public_baseurl = baseUrl;
      listeners = [{
        port = 8008;
        bind_addresses = [ "localhost" ];
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [
            "client"
            "federation"
          ];
          compress = true;
        }];
      }];
    };
  };

  # Register new user
  # export MATRIX_SHARED_SECRET=$(agenix -d matrixSharedSecret.age --identity /etc/ssh/ssh_host_ed25519_key | sed "s/.*: //")
  # nix-shell -p matrix-synapse
  # register_new_matrix_user -k $MATRIX_SHARED_SECRET http://localhost:8008

  # Element client
  services.nginx.virtualHosts."element.${fqdn}" = withBlocklist {
    enableACME = true;
    forceSSL = true;
    serverAliases = [ "element.${config.domainName}" ];
    root = pkgs.element-web.override {
      conf = {
        default_server_config = clientConfig;
      };
    };
  };

  # Postgres
  # CREATE ROLE "matrix-synapse" LOGIN;
  # CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
  #   TEMPLATE template0
  #   LC_COLLATE = "C"
  #   LC_CTYPE = "C";

}
