{ pkgs, inputs, ... }:

let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  users.users.mame.packages = [
    llmAgents.opencode
    llmAgents.grok
  ];
}
