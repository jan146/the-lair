{ config, pkgs, ... }:
let
    useStable = (builtins.compareVersions pkgs.nginxStable.version "1.31.9") >= 0;
    package = if useStable then pkgs.nginxStable else pkgs.nginxMainline;
in
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    appendHttpConfig = ''
      map $http_user_agent $is_clanker {
          default 0;
          ~*(GPTBot|ClaudeBot|OAI-SearchBot|PerplexityBot|Amazonbot|DeepSeekBot|CCBot|CloudVertexBot|Bytespider) 1;
          ~*(ChatGPT|OpenAI|Anthropic|DeepSeek|xAI|x\.ai|perplexity\.ai) 1;
      }
    '';
    inherit package;
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];
  security.acme.certs."${config.domainName}" = {
    reloadServices = [ "nginx" ];
  };
}
