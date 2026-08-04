{ config, pkgs, ... }:
let
  sslCertDir = config.security.acme.certs.${config.domainName}.directory;
in
{
  services.murmur = {
    enable = true;
    port = 64738;
    bandwidth = 256000;
    tls = {
      caPath = "${sslCertDir}/chain.pem";
      certPath = "${sslCertDir}/fullchain.pem";
      keyPath = "${sslCertDir}/key.pem";
    };
  };
  environment.systemPackages = with pkgs; [
    mumble
  ];
}
