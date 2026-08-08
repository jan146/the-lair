vhost@{ extraConfig ? "", ... }:
vhost // {
  extraConfig = (extraConfig) + ''
    # Block AI crawlers that announce themselves in the HTTP user agent.
    if ($is_clanker) {
        return 403;
    }
  '';
}
