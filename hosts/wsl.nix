{ config
, pkgs
, callPackage
, lib
, ...
}:
{
  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
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
  };
}
