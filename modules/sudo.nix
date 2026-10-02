{ ... }:
{
  # Wheel users don't need to enter password
  security.sudo.wheelNeedsPassword = false;
  # Preserve ssh-agent session
  security.sudo.extraConfig = ''
    Defaults env_keep += "SSH_AUTH_SOCK"
  '';
}
