{ config, pkgs, ... }:

{
  imports = [
    ./modules/cli.nix
    ./modules/desktop.nix
    ./modules/user.nix
    ./modules/ai.nix
  ];

  home.username = if pkgs.stdenv.isDarwin then "t.lange" else "thomas";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/t.lange" else "/home/thomas";

  # Keep state version aligned with your nixpkgs release channel
  home.stateVersion = "26.05";
}
