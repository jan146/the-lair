{ config, pkgs, ... }:
let
  sslCertDir = config.security.acme.certs.${config.domainName}.directory;
in
{
  security.acme = {
    certs."${config.domainName}" = {
      extraDomainNames = [ "mumble.${config.domainName}" ];
      reloadServices = [ "murmur" ];
      postRun = ''
        # set permission on dir
        ${pkgs.acl}/bin/setfacl -m \
        u:murmur:rx \
        /var/lib/acme/${config.domainName}

        # set permission on key file
        ${pkgs.acl}/bin/setfacl -m \
        u:murmur:rx \
        /var/lib/acme/${config.domainName}/*.pem
      '';
    };
  };
  services.murmur = {
    enable = true;
    port = 64738;
    openFirewall = true;
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
