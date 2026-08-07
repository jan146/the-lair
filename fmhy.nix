{ config, ... }:
{
  virtualisation.oci-containers.containers.fmhy = {
    image = "ghcr.io/jan146/fmhy:latest";
    ports = [
      "4173:80"
    ];
  };
  services.nginx = {
    virtualHosts."fmhy.${config.domainName}" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4173";
      };
    };
  };
}
