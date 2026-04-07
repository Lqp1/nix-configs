{ pkgs, ... }:
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
