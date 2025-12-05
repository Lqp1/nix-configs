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

  # Don't save coredumps
  systemd.coredump.extraConfig = ''
    Storage=none
  '';

  # Enable the various daemons
  services.openssh.enable = false;
  services.fwupd.enable = true;
  services.thermald.enable = true;

  services.acpid.enable = true;

  virtualisation.docker.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.enable = true;
  networking.networkmanager = {
    enable = true;
    ethernet.macAddress = "random";
    wifi = {
      macAddress = "random";
      scanRandMacAddress = true;
    };
    # Enable IPv6 privacy extensions in NetworkManager.
    connectionConfig."ipv6.ip6-privacy" = 2;
  };

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
    "fs.suid_dumpable" = 0;
    "kernel.dmesg_restrict" = "1";
    "kernel.ftrace_enabled" = false;
    "kernel.io_uring_disabled" = 2;
    "kernel.kptr_restrict" = 2;
    "kernel.randomize_va_space" = "2";
    "kernel.sysrq" = 0;
    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_enable" = false;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.conf.all.accept_redirects" = "0";
    "net.ipv4.conf.all.forwarding" = 0;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.default.forwarding" = "0";
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.conf.default.send_redirects" = "0";
    "net.ipv4.icmp_echo_ignore_broadcasts" = true;
    "net.ipv4.ip_forward" = "0";
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.forwarding" = "0";
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.default.forwarding" = "0";
    "vm.swappiness" = 1;
  };

  boot.blacklistedKernelModules = [
    "cdrom"
    "sr_mod"
    "amd76x_edac"
    "ath_pci"
    "evbug"
    "pcspkr"
    "snd_aw2"
    "snd_intel8x0m"
    "snd_pcsp"
    "usbkbd"
    "usbmouse"
  ];

  environment.etc."modprobe.d/disable-uneeded-kmodules.conf" = {
    text = ''
      install mei /usr/bin/false
      install mei-gsc /usr/bin/false
      install mei_gsc_proxy /usr/bin/false
      install mei_hdcp /usr/bin/false
      install mei-me /usr/bin/false
      install mei_phy /usr/bin/false
      install mei_pxp /usr/bin/false
      install mei-txe /usr/bin/false
      install mei-vsc /usr/bin/false
      install mei-vsc-hw /usr/bin/false
      install mei_wdt /usr/bin/false
      install microread_mei /usr/bin/false
      install ax25 /usr/bin/false
      install netrom /usr/bin/false
      install rose /usr/bin/false
      install tipc /usr/bin/false
      install dccp /usr/bin/false
      install sctp /usr/bin/false
      install rds /usr/bin/false
      install adfs /usr/bin/false
      install affs /usr/bin/false
      install bfs /usr/bin/false
      install befs /usr/bin/false
      install cramfs /usr/bin/false
      install efs /usr/bin/false
      install erofs /usr/bin/false
      install exofs /usr/bin/false
      install freevxfs /usr/bin/false
      install f2fs /usr/bin/false
      install hfs /usr/bin/false
      install hpfs /usr/bin/false
      install jfs /usr/bin/false
      install minix /usr/bin/false
      install nilfs2 /usr/bin/false
      install ntfs /usr/bin/false
      install omfs /usr/bin/false
      install qnx4 /usr/bin/false
      install qnx6 /usr/bin/false
      install sysv /usr/bin/false
      install ufs /usr/bin/false
    '';
  };

  users.users.root.hashedPassword = "!";
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
      text = "${lib.getExe inputs.nixos-needsreboot.packages.${pkgs.stdenv.hostPlatform.system}.default} \"$systemConfig\" || true";
    };
  };
}
