{ pkgs, ... }:

{
  imports = [
    ./modules/cli.nix
    ./modules/desktop.nix
    ./modules/user.nix
    ./modules/ai.nix
    ./modules/k8s.nix
  ];

  home.username = if pkgs.stdenv.isDarwin then "t.lange" else "thomas";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/t.lange" else "/home/thomas";

  # Keep state version aligned with your nixpkgs release channel
  home.stateVersion = "26.05";

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
  ];
}
