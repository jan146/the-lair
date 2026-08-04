let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgosVEivuizfByPTS8O/4CIX2+1P2HwDN1/7u3Ottrd";
  users = [ user1 ];

  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGg8BX54c5bJiIonkkvBqB9w4iB3ZZCmnISqvrbFA5rd";
  systems = [ system1 ];
in
{
  "docmostEnv.age".publicKeys = [ user1 system1 ];
  "porkbunApiKey.age".publicKeys = [ user1 system1 ];
  "porkbunSecretApiKey.age".publicKeys = [ user1 system1 ];
}
