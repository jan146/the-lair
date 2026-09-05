let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgosVEivuizfByPTS8O/4CIX2+1P2HwDN1/7u3Ottrd";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGg8BX54c5bJiIonkkvBqB9w4iB3ZZCmnISqvrbFA5rd";
  agenixFiles = [
    "docmostEnv.age"
    "porkbunApiKey.age"
    "porkbunSecretApiKey.age"
    "ddnsUpdaterConfig.age"
    "homarrEnv.age"
    "invidiousBasicAuth.age"
    "invidiousExtraSettings.age"
    "wgKey.age"
    "nextcloudPass.age"
    "invidiousEnv.age"
    "invidiousPgPass.age"
    "searxngEnv.age"
    "searxngBasicAuth.age"
    "matrixSharedSecret.age"
  ];
in
  builtins.listToAttrs (
    map (file:
      {name = file; value = {
        publicKeys = [ user system ];
      };}
    ) agenixFiles
  )
