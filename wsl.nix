{ config
, pkgs
, callPackage
, ...
}:
{
  system.stateVersion = "24.05";
  wsl.enable = true;
  wsl.defaultUser = "thomas";
}
