{ inputs
, lib
, pkgs
, ...
}:
let
  disabledModules = [
    "adfs"
    "affs"
    "algif_aead" # CVE-2026-31431
    "amd76x_edac"
    "ath_pci"
    "ax25"
    "befs"
    "bfs"
    "cdrom"
    "cramfs"
    "efs"
    "erofs"
    "esp4" # https://github.com/V4bel/dirtyfrag
    "esp6" # https://github.com/V4bel/dirtyfrag
    "evbug"
    "exofs"
    "f2fs"
    "freevxfs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "netrom"
    "nilfs2"
    "ntfs"
    "omfs"
    "pcspkr"
    "qnx4"
    "qnx6"
    "rose"
    "rxrpc" # https://github.com/V4bel/dirtyfrag
    "snd_aw2"
    "snd_intel8x0m"
    "snd_pcsp"
    "sr_mod"
    "sysv"
    "ufs"
    "usbkbd"
    "usbmouse"
  ];
in
{

  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  security.pam.services.passwd.rules.password."unix".settings.rounds = 65536;

  security.allowSimultaneousMultithreading = false;
  security.protectKernelImage = true;

  security.forcePageTableIsolation = true;
  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules = [
    "-a exit,always -F arch=b64 -S execve"
  ];

  security.rtkit.enable = true;

  # Don't save coredumps
  systemd.coredump.extraConfig = ''
    Storage=none
  '';

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.enable = true;
  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;
  programs.firejail.enable = true;
  boot.kernel.sysctl = {
    "dev.tty.ldisc_autoload" = 0;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = 0;
    "kernel.dmesg_restrict" = "1";
    "kernel.ftrace_enabled" = false;
    "kernel.io_uring_disabled" = 2;
    "kernel.kptr_restrict" = 2;
    #"kernel.modules_disabled" = 1; #Ideally!
    "kernel.oops_limit" = 100;
    "kernel.perf_event_paranoid" = 3;
    "kernel.randomize_va_space" = "2";
    "kernel.sysrq" = 0;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.warn_limit" = 100;
    "kernel.yama.ptrace_scope" = 3;
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
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.forwarding" = "0";
    "net.ipv6.conf.default.accept_ra" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.default.forwarding" = "0";
    #"user.max_user_namespaces" = 0; # Prevents some sandboxing
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;
    "vm.swappiness" = 1;
  };

  boot.blacklistedKernelModules = disabledModules;
  environment.etc."modprobe.d/disable-unneeded-kmodules.conf".text =
    lib.concatMapStringsSep "\n" (m: "install ${m} /usr/bin/false") disabledModules + "\n";

  boot.kernelParams = [
    "slab_nomerge"
    "page_poison=1"
    "page_alloc.shuffle=1"
    "debugfs=off"
  ];
  users.users.root.hashedPassword = "!";
}
