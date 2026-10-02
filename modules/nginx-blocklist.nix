vhost@{ locations ? {},... }:
let
  addRobotsLocation = locations: locations // {
    "/robots.txt" = locations."/robots.txt" or {
      return = ''200 "User-agent: *\nDisallow: /\n"'';
    };
  };
  addExtraConfig = locations: (builtins.mapAttrs(location: conf: conf // {
    extraConfig = (conf.extraConfig or "") + ''
      # Block AI crawlers that announce themselves in the HTTP user agent.
      if ($is_clanker) {
          return 403;
      }
    '';
  })) locations;
in
vhost // {
  locations = addRobotsLocation (addExtraConfig locations);
}
