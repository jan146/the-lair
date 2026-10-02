{ config, ... }:
let
  username = config.username;
in
{
  hjem.users."${username}" = {
    enable = true;
    user = username;
    directory = config.users.users."${username}".home;
    clobberFiles = false;
  };
}
