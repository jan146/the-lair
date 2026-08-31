{ config, ... }:
let
  withBlocklist = import ./nginx-blocklist.nix;
in
{
  services = {
    pihole-ftl = {
      enable = true;
      # queryLogDeleter.enable = true;
      openFirewallDNS = true;
      lists = [
        {
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          type = "block";
          enabled = true;
          description = "Steven Black's HOSTS";
        }
        {
          url = "https://media.githubusercontent.com/media/zachlagden/Pi-hole-Optimized-Blocklists/main/lists/all_domains.txt";
          type = "block";
          enabled = true;
          description = "zachlagden's optimized blocklist";
        }
      ];
      settings = {
        # misc.readOnly = false;
        dns = {
          domainNeeded = true;
          interface = config.networking.defaultGateway.interface;
          upstreams = ["9.9.9.9" "1.1.1.1" "8.8.8.8"];
          queryLogging = false;
        };
        misc.privacylevel = 3;
        webserver = {
          api = {
            # To manage the web login:
            # 1) Temporarily set misc.readOnly to false in
            #    configuration.nix and switch to it.
            # 2) Manually set a password:
            #    Pi-hole web console > Settings > All settings >
            #    Webserver and API > webserver.api.password > Value: ******
            # 3) Read the generated hash:
            #    sudo pihole-FTL --config webserver.api.pwhash
            pwhash = "$BALLOON-SHA256$v=1$s=1024,t=32$siKXmd1lzdoO5rw0biqjSQ==$/kvNPNVckVSh112Xr2WRqNNCZdrvIEBq4dMfaRp4crY=";
          };
        };
      };
    };

    pihole-web = {
      enable = true;
      ports = [3002];
    };
  };

  # The following silences a benign FTL.log warning:
  # WARNING API: Failed to read /etc/pihole/versions (key: internal_error)
  systemd.tmpfiles.rules = [
    # Type Path Mode User Group Age Argument
    "f /etc/pihole/versions 0644 pihole pihole - -"
  ];

  services.nginx = {
    virtualHosts."pihole.${config.domainName}" = withBlocklist {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3002";
      };
    };
  };
}

