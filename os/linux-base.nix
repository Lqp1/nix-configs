{ config
, inputs
, lib
, pkgs
, ...
}:
let
  nameservers = [
    "9.9.9.9"
    "149.112.112.112"
    "2620:fe::fe"
    "2620:fe::9"
  ];
in
{
  imports = [
    ../base.nix
    ./linux-tmpfs.nix
    ./linux-security.nix
  ];

  options = {
    my.use-resolved = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use systemd-resolved as the DNS resolver";
    };
  };

  config = {

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

    # systemd logrotate serrvice
    services.logrotate.enable = true;

    boot.loader.systemd-boot.configurationLimit = 5;
    boot.loader.grub.configurationLimit = 5;


    # Enable the various daemons
    services.openssh.enable = false;
    services.fwupd.enable = true;
    services.thermald.enable = true;

    services.acpid.enable = true;

    virtualisation.docker.enable = true;

    networking.networkmanager = {
      enable = true;
      ethernet.macAddress = "random";
      wifi = {
        macAddress = "random";
        scanRandMacAddress = true;
      };
      # Enable IPv6 privacy extensions in NetworkManager.
      connectionConfig."ipv6.ip6-privacy" = 2;
      dns = lib.mkIf config.my.use-resolved "systemd-resolved";
    };

    services.resolved.enable = config.my.use-resolved;
    services.resolved.settings.Resolve = {
      DNSSEC = "false";
      DNSOverTLS = "true";
      LLMNR = "false";
      Domains = [ "~." ];
      FallbackDns = nameservers;
    };
    networking.nameservers = nameservers;


    programs.less.enable = true;
    programs.iotop.enable = true;

    hardware.enableRedistributableFirmware = true;

    nix.settings.max-jobs = 4;
    nix.settings.allowed-users = [ "@wheel" ];
    nix.gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 60d";
    };
    system.activationScripts = {
      nixos-needsreboot = {
        supportsDryActivation = true;
        text = "${lib.getExe inputs.nixos-needsreboot.packages.${pkgs.stdenv.hostPlatform.system}.default} \"$systemConfig\" || true";
      };
    };
  };
}
