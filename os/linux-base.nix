{ inputs
, lib
, config
, pkgs
, callPackage
, ...
}:
{

  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  security.pam.services.passwd.rules.password."unix".settings.rounds = 65536;

  security.allowSimultaneousMultithreading = false;

  security.forcePageTableIsolation = true;
  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules = [
    "-a exit,always -F arch=b64 -S execve"
  ];

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

  # systemd logrotate serrvice
  services.logrotate.enable = true;

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

  ## Sysctk & Kernel security settings from:
  # https://github.com/NixOS/nixpkgs/blob/d1adf7652500d3ef98cdadb411b6aea20e2d4339/nixos/modules/profiles/hardened.nix
  # https://github.com/cynicsketch/nix-mineral/blob/main/nix-mineral.nix

  boot.kernel.sysctl = {
        "dev.tty.ldisc_autoload" = 0;
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;
        "kernel.kptr_restrict" = 2;
        "fs.suid_dumpable" = 0;
        "kernel.sysrq" = 0;
        "kernel.unprivileged_bpf_disabled" = 1;
        "kernel.ftrace_enabled" = false;
        "net.core.bpf_jit_enable" = false;
        "net.core.bpf_jit_harden" = 2;
        "net.ipv4.conf.all.forwarding" = 0;
        "net.ipv4.conf.all.log_martians" = 1;
        "net.ipv4.conf.all.rp_filter" = 1;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.default.log_martians" = 1;
        "net.ipv4.icmp_echo_ignore_broadcasts" = true;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
      };

  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Rare protocols
    "tipc"
    "dccp"
    "sctp"
    "rds"

    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "ntfs"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

  nix.settings.max-jobs = 4;
  nix.settings.auto-optimise-store = true;
  nix.settings.allowed-users = [ "@wheel" ];
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
