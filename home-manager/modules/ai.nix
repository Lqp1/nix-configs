{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
  ];

  home.file.".gemini/antigravity-cli/settings.json" = {
    text = builtins.toJSON {
      terminal_sandbox = true;
      tool_permission = "request-review";
      non_workspace_file_access = "ask";
      internet_access_policy = "ask";
      artifact_review_mode = "asks-for-review";
      color_scheme = "solarized dark";
    };
    force = true;
  };
}
