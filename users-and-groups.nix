{ config, ... }:
let
  username = config.username;
in
{
  users.users."${username}" = {
    isNormalUser = true;
    home = "/home/${username}";
    uid = 1000;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [];
  };
  users.groups."users" = {
    name = "users";
    gid = 100;
    members = [ username ];
  };
}
