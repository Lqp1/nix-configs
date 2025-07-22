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
    veracrypt
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
    pulseaudio
    networkmanagerapplet
  ];

  # List services that you want to enable:
  services.fstrim.enable = true;

  # VPN
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  # Enable the various daemons
  services.openssh.enable = false;
  services.fwupd.enable = true;
  services.thermald.enable = true;
  services.gvfs.enable = true;
  services.gvfs.package = pkgs.lib.mkForce pkgs.gvfs;


  services.redshift = {
    enable = lib.mkDefault true;
    temperature = {
      day = 5500;
      night = 3500;
    };
  };

  services.acpid.enable = true;

  virtualisation.docker.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.enable = true;
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [
    pkgs.hplipWithPlugin
    pkgs.sane-airscan
  ];

  # Enables sound using PW
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable bt
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
      General = {
          Experimental = true;
      };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "fr";
  services.xserver.xkb.options = "eurosign:e,compose:rctrl";
  services.xserver.desktopManager.wallpaper.mode = "max";
  services.libinput.enable = true;
  services.displayManager = {
    defaultSession = "none+i3";
  };
  services.xserver.desktopManager = {
    xterm.enable = false;
  };
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages =
      with pkgs;
      let
        polybar = pkgs.polybar.override {
          i3Support = true;
          pulseSupport = true;
        };
      in
      [
        rofi
        xdotool
        feh
        arandr
        polybar
        i3lock
        pkgs.xfce.xfce4-terminal
        arc-icon-theme
        arc-theme
        pkgs.xfce.xfce4-screenshooter
        pkgs.xfce.thunar
        pkgs.xfce.ristretto
        xclip
        pkgs.xfce.xfce4-settings
        pkgs.xfce.xfce4-power-manager
        pkgs.xfce.xfce4-clipman-plugin
        pkgs.xfce.xfconf
        pkgs.xfce.exo
        pkgs.xfce.tumbler
        dunst
        picom
        xss-lock
      ];
  };

  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;
  services.autorandr.enable = true;

  hardware.acpilight.enable = true;

  # Temp fix for https://github.com/NixOS/nixpkgs/issues/292638
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="kbd_backlight", GROUP="video", MODE="0664"
  '';

  programs.evince.enable = true;
  programs.file-roller.enable = true;
  programs.less.enable = true;
  programs.iotop.enable = true;
  programs.firejail.enable = true;
  programs.adb.enable = true;
  programs.nm-applet.enable = true;

  users.users.thomas = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "clamav"
      "docker"
      "video"
      "plugdev"
    ];
    packages = with pkgs; [
      firefox
      vlc
      transmission_4
      gimp
      libreoffice
      pavucontrol
      gsmartcontrol
      gparted
      audacity
    ];
    shell = pkgs.zsh;
  };
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
