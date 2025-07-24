{ inputs
, lib
, config
, pkgs
, callPackage
, ...
}:
{

  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  security.rtkit.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };

  location = {
    latitude = 48.86;
    longitude = 2.333;
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    powertop
    unzip
    p7zip
    ccze
    samba
    lshw
    usbutils
    mtpfs
    hdparm
    lm_sensors
    iptraf-ng
    fwupd
  ];

  # List services that you want to enable:
  services.fstrim.enable = true;

  # Enable the various daemons
  services.openssh.enable = false;
  services.fwupd.enable = true;
  services.thermald.enable = true;

  services.acpid.enable = true;

  virtualisation.docker.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.enable = true;
  networking.networkmanager.enable = true;

  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;

  programs.less.enable = true;
  programs.iotop.enable = true;
  programs.firejail.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  nix.settings.max-jobs = 4;
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 60d";
  };
  system.activationScripts = {
    nixos-needsreboot = {
      supportsDryActivation = true;
      text = "${lib.getExe inputs.nixos-needsreboot.packages.${pkgs.system}.default} \"$systemConfig\" || true";
    };
  };
}
