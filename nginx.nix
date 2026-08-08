{ ... }:
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
  };
}
