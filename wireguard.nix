{ config, pkgs, ... }:
{
  networking.nat.enable = true;
  networking.nat.externalInterface = config.networking.defaultGateway.interface;
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  age.secrets.wgPrivKey = {
    file = ./secrets/wgKey.age;
    owner = "root";
    group = "root";
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';
      privateKeyFile = config.age.secrets.wgPrivKey.path;
      peers = [
        { # jan
          publicKey = "5ZBBbhq/YNEyqXZ5jnlFXU9z/5LdO8yxvWVUx4NhPDk=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
        { # other
          publicKey = "PkO+Jupm+mDqT45KW1Lum3s+ESrULtLgmNLP8nppri4=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
}
