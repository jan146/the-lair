{ config, pkgs, ... }:
let
  domainName = config.domainName;
in
{
  age.secrets = {
    porkbunApiKey = {
      file = ./secrets/porkbunApiKey.age;
      owner = config.username;
      group = "users";
    };
    porkbunSecretApiKey = {
      file = ./secrets/porkbunSecretApiKey.age;
      owner = config.username;
      group = "users";
    };
  };
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
        "PORKBUN_API_KEY_FILE" = config.age.secrets.porkbunApiKey.path;
        "PORKBUN_SECRET_API_KEY_FILE" = config.age.secrets.porkbunSecretApiKey.path;
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
