# Config for linux workstation configs
{ config
, inputs
, lib
, pkgs
, ...
}:
let
  inherit (config.my) linuxType;

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
    (readonly (noescape "~/.config/git"))
    (readwrite (noescape "~/.config/opencode"))
    (add-pkg-deps (with pkgs; [ git ripgrep bashInteractive curl jq yq ]))
  ]);
in
{
  imports = [
    ./linux-base.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  options = {

    my.linuxType = lib.mkOption {
      type = lib.types.enum [ "laptop" "desktop" "none" ];
      default = "none";
      description = "Whether this is a desktop (GNOME + avahi) rather than a laptop (i3)";
    };

  };

  config = {

    my.sudoWrapper = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      users.thomas = {
        imports = [ ../home-manager/home.nix ];
        services.redshift.enable = linuxType == "laptop";
      };
    };

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
      hunspell
      hunspellDicts.fr-moderne
      hunspellDicts.en_US
      android-tools

      # Workstation desktop apps (machine/family scope)
      libreoffice
      vlc
      transmission_4
      gimp
      gthumb
      pavucontrol
      gsmartcontrol
      gparted
      audacity
      naps2
    ] ++ lib.optionals (linuxType == "laptop") [ usbguard-select ];

    environment.sessionVariables = {
      DICPATH = "/run/current-system/sw/share/hunspell";
    };

    programs.firefox = {
      enable = true;
      languagePacks = [ "fr" "en-US" ];
      policies = {
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
          "fr-dicollecte@dictionaries.addons.mozilla.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/dictionnaire-français1/latest.xpi";
          };
          "@unitedstatesenglishdictionary" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/us-english-dictionary/latest.xpi";
          };
        };
      };
    };

    services.avahi.enable = linuxType == "desktop";

    programs.captive-browser.enable = linuxType == "laptop";
    programs.dconf.enable = true;

    # VPN
    services.tailscale =
      {
        enable = true;
        useRoutingFeatures = "client";
        disableUpstreamLogging = true;
        disableTaildrop = true;
        extraSetFlags = [ "--netfilter-mode=on" "--accept-routes=true" "--accept-dns=true" ];
        extraDaemonFlags = [ "--no-logs-no-support" ];
      };

    # Enable the various daemons
    services.gvfs.enable = true;
    services.gvfs.package = pkgs.lib.mkForce pkgs.gvfs;


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
          extraPackages = with pkgs; [
            xdotool
            feh
            arandr
            i3lock-color
            xfce4-terminal
            xfce4-screenshooter
            file-roller
            ristretto
            xclip
            libnotify
            catfish
            xfce4-settings
            xfce4-power-manager
            xfce4-clipman-plugin
            xfconf
            xfce4-exo
            snixembed
            xss-lock
          ];
        };

      };

    services.desktopManager.gnome.enable = linuxType == "desktop";
    services.libinput =
      let
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
    services.autorandr.hooks.postswitch = {
      "reload-wm" = ''
        ${pkgs.procps}/bin/pkill -USR1 polybar || true
        if ! ${pkgs.procps}/bin/pgrep -f i3lock >/dev/null; then
          [ -x ~/.fehbg ] && ~/.fehbg || true
          ${pkgs.i3}/bin/i3-msg restart || true
        fi
      '';
    };

    hardware.acpilight.enable = true;

    services.pcscd.enable = true;

    services.udev.packages = [ pkgs.sane-airscan pkgs.yubikey-personalization ];
    # Temp fix for https://github.com/NixOS/nixpkgs/issues/292638
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="kbd_backlight", GROUP="video", MODE="0664"
    '';

    programs.evince.enable = true;
    programs.nm-applet.enable = true;

    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
      ];
    };
    services.tumbler.enable = true;


    services.tlp = lib.mkIf (linuxType == "laptop") {
      enable = true;
      settings = {
        # ThinkPad battery charge thresholds (preserves battery cycle life)
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
        START_CHARGE_THRESH_BAT1 = 75;
        STOP_CHARGE_THRESH_BAT1 = 80;
      };
    };
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

    specialisation.Powersave = lib.mkIf (linuxType == "laptop") {
      inheritParentConfig = true;
      configuration = { options, ... }: {
        environment.sessionVariables = {
          NIXOS_SPECIALISATION = "Powersave";
        };
        environment.etc."specialisation".text = "Powersave";

        boot.kernelParams = lib.mkForce [
          "slab_nomerge"
          "page_poison=1"
          "page_alloc.shuffle=1"
          "debugfs=on"
          "intel_pstate=no_turbo"
          "i915.enable_fbc=1"
          "i915.enable_psr=1"
          "nmi_watchdog=0"
        ];
        boot.kernel.sysctl = {
          "kernel.nmi_watchdog" = 0;
        };
        powerManagement.cpuFreqGovernor = lib.mkForce "powersave";
        hardware.bluetooth.powerOnBoot = lib.mkForce false;
        services.tlp.settings = lib.mkIf (options ? services && options.services ? tlp) {
          CPU_ENERGY_PERF_POLICY_ON_AC = "power";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_BOOST_ON_AC = 0;
          CPU_BOOST_ON_BAT = 0;
          CPU_HWP_DYN_BOOST_ON_AC = 0;
          CPU_HWP_DYN_BOOST_ON_BAT = 0;
          PLATFORM_PROFILE_ON_AC = "low-power";
          PLATFORM_PROFILE_ON_BAT = "low-power";
        };
      };
    };
  };
}
