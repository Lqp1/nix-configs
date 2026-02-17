{ inputs
, lib
, config
, pkgs
, callPackage
, ...
}:
{

  environment.systemPackages = with pkgs; [
    veracrypt
    pulseaudio
    networkmanagerapplet
  ];

  services.avahi.enable = pkgs.lib.mkDefault false;

  # VPN
  services.tailscale =
    {
      enable = true;
      useRoutingFeatures = "client";
      disableUpstreamLogging = true;
      disableTaildrop = true;
      extraSetFlags = [ "--netfilter-mode=on" "--accept-routes" ];
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };

  # Enable the various daemons
  services.gvfs.enable = true;
  services.gvfs.package = pkgs.lib.mkForce pkgs.gvfs;

  services.redshift = {
    enable = lib.mkDefault true;
    temperature = {
      day = 5500;
      night = 3500;
    };
  };

  # Enable CUPS to print documents.
  #services.printing.logLevel = "debug";
  services.printing = {
    enable = true;
    browsed.enable = false;
    browsing = false;
    drivers = [ pkgs.hplipWithPlugin ];
    extraConf = ''
      ErrorPolicy retry-job
    '';
  };
  hardware.printers = {
    ensurePrinters = [
      {
        name = "HP3639";
        location = "Bureau";
        deviceUri = "hp:/net/DeskJet_3630_series?ip=192.168.1.40";
        model = "HP/hp-deskjet_3630_series.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
        };
      }
      # Potentially use IPP Eve instead; we could then cleanup all references to hplipWithPlugin
      #{
      #  name = "HP3639-IPP";
      #  location = "Bureau";
      #  deviceUri = "ipp://192.168.1.40/ipp/print";
      #  model = "everywhere";
      #}
    ];
    ensureDefaultPrinter = "HP3639";
  };

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
  hardware.bluetooth.powerOnBoot = true;
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
        material-cursors
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

  services.autorandr.enable = true;

  hardware.acpilight.enable = true;

  services.udev.packages = [ pkgs.sane-airscan ];
  # Temp fix for https://github.com/NixOS/nixpkgs/issues/292638
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="kbd_backlight", GROUP="video", MODE="0664"
  '';

  programs.evince.enable = true;
  programs.adb.enable = true;
  programs.nm-applet.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  users.users.thomas = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Admin of the system
      "networkmanager"
      "clamav" # To trigger scans
      "docker" # To manipulate docker
      "video"
      "plugdev"
      "adbusers" # To use ADB
      "dialout" # For Arduino / Esp32 access through tty
    ];
    packages = with pkgs; [
      firefox
      vlc
      transmission_4
      gimp
      gthumb
      libreoffice
      pavucontrol
      gsmartcontrol
      gparted
      audacity
      naps2
    ];
    shell = pkgs.zsh;
  };

  # Hide logs or on workstations & add plymouth
  boot.loader.timeout = 0;
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
  ];
  boot.plymouth = {
    enable = true;
    theme = "pixels";
    themePackages = with pkgs; [
      (adi1090x-plymouth-themes.override {
        selected_themes = [ "pixels" ];
      })
    ];
  };

}
