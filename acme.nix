{ config, pkgs, ... }:
let
  domainName = config.domainName;
in
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@${domainName}";
    # defaults.webroot = "/var/lib/acme/acme-challenge/";
    certs."${domainName}" = {
      # group = config.services.nginx.group;
      extraDomainNames = [
        "mumble.${domainName}"
      ];
      dnsProvider = "porkbun";
      credentialFiles = {
        "PORKBUN_API_KEY_FILE" = "/etc/porkbun/PORKBUN_API_KEY_FILE";
        "PORKBUN_SECRET_API_KEY_FILE" = "/etc/porkbun/PORKBUN_SECRET_API_KEY_FILE";
      };
      reloadServices = [
        "murmur"
        # "nginx"
      ];
      postRun = ''
        # set permission on dir
        ${pkgs.acl}/bin/setfacl -m \
        u:murmur:rx \
        /var/lib/acme/${domainName}

        # set permission on key file
        ${pkgs.acl}/bin/setfacl -m \
        u:murmur:rx \
        /var/lib/acme/${domainName}/*.pem
      '';
    };
  };
}
