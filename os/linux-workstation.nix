{ config
, inputs
, lib
, pkgs
, ...
}:
let
  inherit (config.my) linuxType;
  useNeovim = config.my.editor == "neovim";
  staticResolvConf = pkgs.writeText "jailed-resolv.conf" ''
    nameserver 1.1.1.1
    nameserver 9.9.9.9
    options edns0
  '';
  usbguard-select = pkgs.callPackage ../derivations/usbguard-select { };
  jail = inputs.jail-nix.lib.extend {
    inherit pkgs;
    additionalCombinators = builtinCombinators: with builtinCombinators; {
      # Add custom combinator to prevent attempting to bind mount systemd stub resolved
      # Should be removed once upstream fixed it
      my-network = state: compose [
        (share-ns "net")
        (runtime-deep-ro-bind "/etc/hosts")
        (runtime-deep-ro-bind "/etc/nsswitch.conf")
        (bind-pkg "/etc/resolv.conf" staticResolvConf)
        (runtime-deep-ro-bind "/etc/ssl")
        (write-text "/etc/hostname" "${state.hostname}\n")
        (unsafe-add-raw-args "--hostname ${escape state.hostname}")
      ]
        state;
    };
  };
  jailed-opencode = jail "jailed-opencode" pkgs.opencode (with jail.combinators; [
    my-network
    time-zone
    no-new-session
    mount-cwd
    (readonly (noescape "~/.gitconfig"))
    (readwrite (noescape "~/.config/opencode"))
    (add-pkg-deps (with pkgs; [ git ripgrep bashInteractive curl jq yq ]))
  ]);
in
{
  imports = [
    ./linux-base.nix
    ../workstation.nix
    ./linux-polkit.nix
  ];

  options = {
    my.editor = lib.mkOption {
      type = lib.types.enum [ "neovim" "vim" ];
      default = "neovim";
      description = "Default editor";
    };
    my.linuxType = lib.mkOption {
      type = lib.types.enum [ "laptop" "desktop" "none" ];
      default = "none";
      description = "Whether this is a desktop (GNOME + avahi) rather than a laptop (i3)";
    };
  };

  config = {
    assertions = [
      {
        assertion = linuxType != "none";
        message = "linuxType must not be \"none\"";
      }
    ];

    environment.systemPackages = with pkgs; [
      veracrypt
      pulseaudio
      networkmanagerapplet
      libreoffice
      hunspell
      hunspellDicts.fr-moderne
      hunspellDicts.en_US
      android-tools
    ] ++ lib.optionals (linuxType == "laptop") [ usbguard-select ];

    services.avahi.enable = linuxType == "desktop";

    programs.captive-browser.enable = true;

    # VPN
    services.tailscale =
      {
        enable = true;
        useRoutingFeatures = "client";
        disableUpstreamLogging = true;
        disableTaildrop = true;
        extraSetFlags = [ "--netfilter-mode=on" "--accept-routes=true" "--accept-dns=false" ];
        extraDaemonFlags = [ "--no-logs-no-support" ];
      };

    # Enable the various daemons
    services.gvfs.enable = true;
    services.gvfs.package = pkgs.lib.mkForce pkgs.gvfs;

    services.redshift = {
      enable = linuxType == "laptop";
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
    services.xserver =
      {
        enable = true;
        xkb.layout = "fr";
        xkb.options = "eurosign:e,compose:rctrl";
        desktopManager =
          {
            wallpaper.mode = "max";
            xterm.enable = false;
          };
        displayManager =
          {
            lightdm = {
              background = pkgs.nixos-artwork.wallpapers.moonscape.gnomeFilePath;
              greeters.gtk.enable = true;
              greeters.gtk.theme.name = "Arc-Dark";
              greeters.gtk.theme.package = pkgs.arc-theme;
              greeters.gtk.iconTheme.name = "Papirus-Dark";
              greeters.gtk.iconTheme.package = pkgs.papirus-icon-theme;
              greeters.gtk.cursorTheme.name = "material_light_cursors";
              greeters.gtk.cursorTheme.package = pkgs.material-cursors;
            };
          };
        windowManager.i3 = {
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
              xfce4-terminal
              papirus-icon-theme
              arc-theme
              material-cursors
              xfce4-screenshooter
              thunar
              file-roller
              ristretto
              xclip
              xfce4-settings
              xfce4-power-manager
              xfce4-clipman-plugin
              xfconf
              xfce4-exo
              tumbler
              dunst
              picom
              xss-lock
            ];
        };

      };

    services.desktopManager.gnome.enable = linuxType == "desktop";
    services.libinput = let
      opts = {
        tapping = true;
        tappingDragLock = false;
        additionalOptions = ''
          Option "TappingDrag" "off"
          '';
      };
    in
    {
      enable = true;
      touchpad = opts;
      mouse = opts;
    };
    services.displayManager.defaultSession = lib.mkIf (linuxType == "laptop") "none+i3";
    services.autorandr.enable = true;

    hardware.acpilight.enable = true;

    services.pcscd.enable = true;

    services.udev.packages = [ pkgs.sane-airscan pkgs.yubikey-personalization ];
    # Temp fix for https://github.com/NixOS/nixpkgs/issues/292638
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="kbd_backlight", GROUP="video", MODE="0664"
    '';

    programs.evince.enable = true;
    programs.nm-applet.enable = true;

    programs.neovim = {
      enable = useNeovim;
      viAlias = useNeovim;
      vimAlias = useNeovim;
      defaultEditor = useNeovim;
    };

    services.tlp.enable = linuxType == "laptop";
    services.power-profiles-daemon.enable = false; # Conflicts with TLP when activated.
    powerManagement.powertop.enable = false; # Same
    networking.networkmanager.wifi.powersave = linuxType == "laptop";
    powerManagement.enable = true;
    services.upower = lib.mkIf (linuxType == "laptop") {
      enable = true;
      percentageLow = 25;
      percentageCritical = 15;
      percentageAction = 14;
      criticalPowerAction = "Suspend";
      allowRiskyCriticalPowerAction = true; # 😈
    };
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
      HandlePowerKey = "suspend";
    };

    services.usbguard = {
      enable = linuxType == "laptop";
      implicitPolicyTarget = "block";
      presentControllerPolicy = "keep";
      presentDevicePolicy = "allow";
      insertedDevicePolicy = "apply-policy";
      IPCAllowedGroups = [ "wheel" ];
    };

    users.mutableUsers = true;

    users.users.thomas = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Admin of the system
        "networkmanager"
        "clamav" # To trigger scans
        "docker" # To manipulate docker
        "video"
        "plugdev"
        "dialout" # For Arduino / Esp32 access through tty
      ];
      packages = with pkgs; [
        firefox
        vlc
        transmission_4
        gimp
        gthumb
        pavucontrol
        gsmartcontrol
        gparted
        audacity
        naps2
        jailed-opencode
      ];
      shell = pkgs.zsh;
      # TODO: Should be changed anyway on each host! It just prevents being locked out by default
      initialHashedPassword = "$y$j9T$NQnV5fxUh6Dza6fFQkP5B1$zu0JwCqa13sSpt1wvVhGB24xpAyiVKcfmxm06.8YYHA";
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

  };
}
