# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  system.stateVersion = "20.03";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Use the GRUB 2 boot loader.
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  services.xserver.videoDrivers = [ "modesetting" ];
  environment.sessionVariables.TERMINAL = [ "xfce4-terminal" ];
  networking.hostName = "thomas-x201"; # Define your hostname.
  networking.interfaces.enp0s25.useDHCP = true;
  networking.networkmanager.wifi.powersave = true;
  services.tlp.enable = true;

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.initrd.luks.devices.cryptroot = {
    preLVM = true;
    allowDiscards = true;
    device = "/dev/disk/by-uuid/7a8ac9ce-89c1-4920-9d6f-67508329e3a2";
  };
  boot.kernelModules = [ "acpi_call" "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  services = {
    syncthing = {
      enable = true;
      user = "thomas";
      openDefaultPorts = true;
      dataDir = "/home/thomas/Sync";
      configDir = "/home/thomas/.config/syncthing";
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/81cd606e-adac-4ef8-b39a-2a2e223d5c4b";
      options = [ "noatime" "nodiratime" "discard" ];
      fsType = "ext4";
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-uuid/f6149b05-4821-41a6-b169-4f80d26726ef";
      options = [ "noatime" "nodiratime" "discard" "nodev" "nosuid" ];
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/0d46e3fa-bef9-4e6d-8afc-64315ae595e4";
      #options = [ "nodev" "nosuid" "noexec" "discard" "nodiratime" "noatime" ];
      fsType = "ext2";
    };

  fileSystems."/tmp" =
    {
      device = "tmpfs";
      options = [ "nodev" "nosuid" "nodiratime" "noatime" "size=2G" ];
      fsType = "tmpfs";
    };

  fileSystems."/run" =
    {
      device = "tmpfs";
      options = [ "nodev" "nosuid" "nodiratime" "noatime" "size=2G" ];
      fsType = "tmpfs";
    };

  fileSystems."/var/tmp" =
    {
      device = "tmpfs";
      options = [ "nodev" "nosuid" "nodiratime" "noatime" "size=2G" ];
      fsType = "tmpfs";
    };

  swapDevices =
    [
      { device = "/dev/disk/by-uuid/c7bfd33d-4ed6-46ba-b931-8ff5c0b92a9c"; }
    ];

}
