{ config, pkgs, ... }:
{
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation.oci-containers.backend = "podman";
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Useful other development tools
  environment.systemPackages = with pkgs; [
    podman
    # dive # look into docker image layers
    podman-tui # status of containers in the terminal
    # docker-compose # start group of containers for dev
    podman-compose # start group of containers for dev
    # slirp4netns
    # fuse-overlayfs
  ];

  users.users."${config.username}" = {
    linger = true; # Enable lingering so containers persist after ssh exit
    extraGroups = [
      "podman"
    ];
  };

  # Allow non-root containers to access lower port numbers
  # boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

}

