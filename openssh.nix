{ ... }:
{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # Enable agent that remembers private keys
  programs.ssh.startAgent = true;
}
