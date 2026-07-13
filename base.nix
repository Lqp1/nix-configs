# Config for Linux+Darwin, for both headless and workstation machines
{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    coreutils
    curl
    git
    home-manager
    htop
    less
    lsof
    p7zip
    unzip
    vim
  ];

  programs.zsh.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;
  nix.settings.auto-optimise-store = false;
  nixpkgs.config.allowUnfree = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
