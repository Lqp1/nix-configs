{ inputs, lib, pkgs, pkgsUnstable, ... }:
let
  nixpkgsPath = "/etc/nixpkgs/channels/nixpkgs";
  lunchy = pkgs.callPackage ../derivations/lunchy { };
  my-aerospace = pkgs.aerospace.overrideAttrs (oldAttrs:
    let
      custom_version = "0.19.2-Beta";
    in
    {
      version = custom_version;
      src = pkgs.fetchzip {
        url = "https://github.com/nikitabobko/AeroSpace/releases/download/v${custom_version}/AeroSpace-v${custom_version}.zip";
        sha256 = "sha256-6RyGw84GhGwULzN0ObjsB3nzRu1HYQS/qoCvzVWOYWQ=";
      };
    });

in
{
  _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };

  environment.systemPackages = with pkgs; [
    pkgsUnstable.choose-gui
    colima
    docker
    lunchy
  ];

  services.aerospace.enable = true;
  services.aerospace.package = my-aerospace;
  services.aerospace.settings = {
    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;
    default-root-container-layout = "accordion";

    # Mouse follows focus when focused monitor changes
    on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

    mode.main.binding = {
      cmd-shift-p = "move-node-to-monitor --wrap-around next";
      cmd-shift-z = "move-workspace-to-monitor --wrap-around next"; # it's the w on an azerty

      # i3 wraps focus by default
      cmd-j = "focus --boundaries-action wrap-around-the-workspace left";
      cmd-left = "focus --boundaries-action wrap-around-the-workspace left";
      cmd-l = "focus --boundaries-action wrap-around-the-workspace right";
      cmd-right = "focus --boundaries-action wrap-around-the-workspace right";

      cmd-shift-j = "move left";
      cmd-shift-left = "move left";
      cmd-shift-l = "move right";
      cmd-shift-right = "move right";

      cmd-h = "join-with right";
      cmd-shift-f = "macos-native-fullscreen";
      cmd-z = "layout h_accordion"; # "layout tabbed" in i3, is w on an azerty
      cmd-e = "layout h_tiles";

      cmd-shift-space = "layout floating tiling"; # "floating toggle" in i3

      # Not supported, because this command is redundant in AeroSpace mental model.
      # See: https://nikitabobko.github.io/AeroSpace/guide#floating-windows
      #cmd-space = "focus toggle_tiling_floating"

      # `focus parent`/`focus child` are not yet supported, and it"s not clear whether they
      # should be supported at all https://github.com/nikitabobko/AeroSpace/issues/5
      # cmd-a = "focus parent"

      cmd-1 = "workspace 1";
      cmd-2 = "workspace 2";
      cmd-3 = "workspace 3";
      cmd-4 = "workspace 4";
      cmd-5 = "workspace 5";

      cmd-shift-1 = "move-node-to-workspace 1";
      cmd-shift-2 = "move-node-to-workspace 2";
      cmd-shift-3 = "move-node-to-workspace 3";
      cmd-shift-4 = "move-node-to-workspace 4";
      cmd-shift-5 = "move-node-to-workspace 5";

      cmd-shift-c = "reload-config";

      cmd-r = "mode resize";
    };

    mode.resize.binding = {
      h = "resize width -50";
      j = "resize height +50";
      k = "resize height -50";
      l = "resize width +50";
      enter = "mode main";
      esc = "mode main";
    };

    on-window-detected = [
      {
        "if".app-id = "com.google.Chrome";
        run = "move-node-to-workspace 1";
      }
      {
        "if".app-id = "net.kovidgoyal.kitty";
        run = "move-node-to-workspace 2";
      }
      {
        "if".app-id = "us.zoom.xos";
        run = "move-node-to-workspace 3";
      }
      {
        "if".app-id = "com.hnc.Discord";
        run = "move-node-to-workspace 3";
      }
      {
        "if".app-id = "com.tinyspeck.slackmacgap";
        run = "move-node-to-workspace 3";
      }
      {
        "if".app-id = "com.microsoft.Outlook";
        run = "move-node-to-workspace 3";
      }
      {
        "if".app-id = "com.spotify.client";
        run = "move-node-to-workspace 4";
      }
      {
        "if".app-id = "com.electron.logseq";
        run = "move-node-to-workspace 5";
      }
      {
        "if".app-id = "com.cisco.secureclient.gui";
        run = "layout floating";
      }
    ];
  };

  services.skhd.enable = true;
  # Not hot reloaded... https://github.com/nix-darwin/nix-darwin/issues/333
  services.skhd.skhdConfig = ''
    cmd - return : open -n -a "Kitty"
    cmd + shift - d : open -n -a "Launchpad"
    cmd - d : \ls /Users/t.lange/Applications/Home\ Manager\ Apps /Applications/Nix\ Apps /Applications/ /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/|grep '\.app'|choose|xargs --null open -a
    cmd - 0x2B : rofimoji -a clipboard -s neutral
    cmd + shift - j : cat ~/.cache/jira_tickets | choose | cut -d' ' -f1 | tr -d '\n' | pbcopy - && cliclick -w 100 kd:cmd t:v ku:cmd
    alt - tab : aerospace focus-back-and-forth || aerospace workspace-back-and-forth
    cmd - 0x0A : aerospace focus --boundaries-action wrap-around-the-workspace right
    cmd - 0x32 : aerospace focus --boundaries-action wrap-around-the-workspace right
  '';

  system.defaults = {
    menuExtraClock.Show24Hour = true;
    menuExtraClock.ShowSeconds = true;
    dock.autohide = true;
    dock.mru-spaces = false;
    dock.show-recents = false;
    dock.static-only = true;
    controlcenter.Bluetooth = true;
    WindowManager.StandardHideDesktopIcons = false;
    finder.AppleShowAllExtensions = true;
    finder.ShowStatusBar = true;
    finder.FXPreferredViewStyle = "Nlsv";
    finder.AppleShowAllFiles = true;
    finder.ShowPathbar = true;
    screencapture.location = "~/Pictures/";
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain."com.apple.swipescrolldirection" = false;
    NSGlobalDomain."com.apple.keyboard.fnState" = true;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    NSGlobalDomain.NSDisableAutomaticTermination = true;
    NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
    controlcenter.BatteryShowPercentage = true;
    loginwindow.GuestEnabled = false;
    trackpad.Clicking = true;
    trackpad.TrackpadRightClick = true;
  };

  # This is more natural on the MacOS keyboard buuuuut is not with a real PC keyboard :(
  system.keyboard.enableKeyMapping = true;
  system.keyboard.swapLeftCommandAndLeftAlt = false;
  system.keyboard.swapLeftCtrlAndFn = false;

  security.pam.services.sudo_local.touchIdAuth = true;

  # workaround to have flake's derivations available for nix-* commands
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${nixpkgsPath}" ];
  environment.etc."nixpkgs/channels/nixpkgs".source = inputs.nixpkgs;

  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 0; Minute = 0; };
    options = "--delete-older-than 60d";
  };

  system.activationScripts.activateDarwinSettings.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
