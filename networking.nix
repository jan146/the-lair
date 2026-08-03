{ config, pkgs, ... }:
{
  networking = {
    hostName = config.hostname;
    dhcpcd.enable = false;
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "192.168.0.238";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "eth0";
    };
    nameservers = [ "9.9.9.9" "1.1.1.1" ];
    networkmanager = {
      enable = true;
      dns = "none";
    };
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
  };
  environment.systemPackages = with pkgs; [
    ookla-speedtest
    wget
    dnsutils
  ];
}
