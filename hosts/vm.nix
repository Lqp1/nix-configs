({ modulesPath, lib, ... }: {
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];
  virtualisation =
    {
      cores = 2;
      diskSize = 20 * 1024;
      memorySize = 2048;
      forwardPorts = [{ from = "host"; host.port = 2222; guest.port = 22; }];
      graphics = false;
    };

  services = {
    thermald.enable = lib.mkForce false;
    openssh.enable = lib.mkForce true;
    openssh.settings.PasswordAuthentication = true;
    getty.autologinUser = "admin";

  };
  security.sudo.wheelNeedsPassword = false;
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialHashedPassword = "$y$j9T$C6saF1jLcaKQVFZXjpVCt.$CB81YdnzoQb1dej/uSTBAq8aQkF840oAMwIk2bbGJU/";
    openssh.authorizedKeys.keys = [ ];
  };
})
