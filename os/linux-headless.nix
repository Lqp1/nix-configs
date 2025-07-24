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
    packages = with pkgs; [
    ];
    shell = pkgs.zsh;
  };
}
