{ config, lib, pkgs, modulesPath, ... }: {
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  system.primaryUser = "t.lange";

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

}
