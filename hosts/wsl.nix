{ config
, pkgs
, callPackage
, ...
}:
{
  system.stateVersion = "24.05";
  wsl.enable = true;
  wsl.defaultUser = "thomas";
  users.users.thomas = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    packages = with pkgs; [
      unzip
    ];
    shell = pkgs.zsh;
  };
  fileSystems."/mnt/z" = {
    device = "Z:";
    fsType = "drvfs";
  };
}
