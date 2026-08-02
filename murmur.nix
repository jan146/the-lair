{ pkgs, ... }:
{
  services.murmur = {
    enable = true;
    port = 64738;
  };
  environment.systemPackages = with pkgs; [
    mumble
  ];
}
