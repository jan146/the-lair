{ ... }:
{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
  };
  # Enable agent that remembers private keys
  programs.ssh.startAgent = true;
}
