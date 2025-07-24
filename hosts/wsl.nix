{ config
, pkgs
, callPackage
, ...
}:
{
  system.stateVersion = "24.05";
  services.xserver.videoDrivers = [ "modesetting" ];
  wsl.enable = true;
  wsl.defaultUser = "thomas";
  fileSystems."/mnt/z" = {
    device = "Z:";
    fsType = "drvfs";
  };
  programs.nix-ld = {
    # for VSCode
    enable = true;
    package = pkgs.nix-ld-rs; # only for NixOS 24.05
  };
}
