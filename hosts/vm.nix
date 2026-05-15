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
  services.openssh.enable = lib.mkForce true;
  services.openssh.settings.PasswordAuthentication = true;
  security.sudo.wheelNeedsPassword = false;
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialHashedPassword = "$y$j9T$C6saF1jLcaKQVFZXjpVCt.$CB81YdnzoQb1dej/uSTBAq8aQkF840oAMwIk2bbGJU/";
    openssh.authorizedKeys.keys = [ ];
  };
})
