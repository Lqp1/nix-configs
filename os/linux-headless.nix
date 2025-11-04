{ inputs
, lib
, config
, pkgs
, callPackage
, ...
}:
{
  users.users.thomas = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "clamav"
      "docker"
    ];
    shell = pkgs.zsh;
  };
}
