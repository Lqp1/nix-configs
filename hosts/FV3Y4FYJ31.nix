_: {
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  system.primaryUser = "t.lange";
  users.users."t.lange".home = "/Users/t.lange";

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Enable Syncthing for this specific Darwin host
  home-manager.users."t.lange" = {
    services.syncthing.enable = true;
    programs.git.settings.user.signingkey = "/Users/t.lange/.ssh/id_ed25519.pub";
  };
}
