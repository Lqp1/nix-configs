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
      wget # required for VSCode integration
    ];
    shell = pkgs.zsh;
  };
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
