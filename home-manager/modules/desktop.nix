{ config, pkgs, lib, inputs, ... }:

let
  templateFile = path: vars:
    let
      names = builtins.attrNames vars;
      placeholders = map (name: "{{ " + name + " }}") names;
      values = map (name: toString vars.${name}) names;
    in
    lib.replaceStrings placeholders values (builtins.readFile path);

  templateVars = {
    "common_ui_color_palette.blue.background" = "#002028";
    "common_ui_color_palette.blue.surface" = "#073642";
    "common_ui_color_palette.blue.surface_alt" = "#0A4555";
    "common_ui_color_palette.blue.dark" = "#1565C0";
    "common_ui_color_palette.blue.base" = "#1E88E5";
    "common_ui_color_palette.blue.focus" = "#42A5F5";
    "common_ui_color_palette.blue.focus_light" = "#90CAF9";
    "common_ui_color_palette.blue.focus_alt" = "#64B5F6";
    "common_ui_color_palette.blue.light" = "#039BE5";
    "common_ui_color_palette.neutral.text" = "#F6FBFF";
    "common_ui_color_palette.neutral.muted" = "#93A1A1";
    "common_ui_color_palette.neutral.soft" = "#D6EAF8";
    "common_ui_color_palette.neutral.grey" = "#757575";
    "common_ui_color_palette.neutral.blue_gray" = "#546E7A";
    "common_ui_color_palette.accent.mode" = "#E60053";
    "common_ui_color_palette.accent.pink" = "#D81B60";
    "common_ui_color_palette.accent.purple" = "#8E24AA";
    "common_ui_color_palette.accent.deep_purple" = "#5E35B1";
    "common_ui_color_palette.accent.indigo" = "#3949AB";
    "common_ui_color_palette.accent.cyan" = "#00ACC1";
    "common_ui_color_palette.accent.teal" = "#00897B";
    "common_ui_color_palette.accent.brown" = "#6D4C41";
    "common_ui_color_palette.status.red" = "#E53935";
    "common_ui_color_palette.status.red_urgent" = "#EF5350";
    "common_ui_color_palette.status.green" = "#43A047";
    "common_ui_color_palette.status.light_green" = "#7CB342";
    "common_ui_color_palette.status.lime" = "#C0CA33";
    "common_ui_color_palette.status.yellow" = "#FDD835";
    "common_ui_color_palette.status.amber" = "#FFB300";
    "common_ui_color_palette.status.orange" = "#FB8C00";
    "common_ui_color_palette.status.deep_orange" = "#F4511E";
    "common_ui_color_palette.terminal.foreground" = "#D6EAF8";
    "common_ui_color_palette.terminal.red" = "#DC322F";
    "common_ui_color_palette.terminal.green" = "#859900";
    "common_ui_color_palette.terminal.yellow" = "#B58900";
    "common_ui_color_palette.terminal.magenta" = "#D33682";
    "common_ui_color_palette.terminal.cyan" = "#2AA198";
    "common_ui_color_palette.terminal.white" = "#C6D8E0";
    "common_ui_color_palette.terminal.orange" = "#CB4B16";
    "common_ui_color_palette.terminal.muted_green" = "#586E75";
    "common_ui_color_palette.terminal.muted_yellow" = "#657B83";
    "common_ui_color_palette.terminal.bright_white" = "#DDEAF0";
    "common_ui_color_palette.terminal.violet" = "#6C71C4";
    "common_ui_color_palette.shadow.opacity" = "0.35";
    "common_ui_color_palette.shadow.red" = "0.00";
    "common_ui_color_palette.shadow.green" = "0.07";
    "common_ui_color_palette.shadow.blue" = "0.10";
  };
in
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    keepassxc
    rofimoji
    fira-code
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    discord
    spotify
  ];

  # Native Home Manager Window Manager & Bar configuration
  xsession.windowManager.i3 = {
    enable = pkgs.stdenv.isLinux;
    config = null;
    extraConfig = templateFile ../templates/i3.j2 templateVars;
  };

  services.polybar = {
    enable = pkgs.stdenv.isLinux;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
    script = "polybar main &";
    extraConfig = templateFile ../templates/polybar.ini.j2 templateVars;
  };

  # Native Home Manager services/programs configs replacing templates
  services.dunst = {
    enable = pkgs.stdenv.isLinux;
    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        geometry = "300x5-30+20";
        indicate_hidden = true;
        shrink = false;
        transparency = 0;
        notification_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 3;
        frame_color = templateVars."common_ui_color_palette.neutral.muted";
        separator_color = "frame";
        sort = true;
        idle_threshold = 120;
        font = "Noto Sans Mono 12";
        line_height = 0;
        markup = "full";
        format = "[%a] <b>%s</b>\\n%b";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = true;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        icon_position = "left";
        max_icon_size = 32;
        sticky_history = true;
        history_length = 20;
        dmenu = "rofi -dmenu -p dunst:";
        browser = "xdg-open";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        startup_notification = false;
        verbosity = "mesg";
        corner_radius = 5;
        force_xinerama = false;
        mouse_left_click = "close_current";
        mouse_middle_click = "close_all";
        mouse_right_click = "do_action";
      };
      experimental = {
        per_monitor_dpi = false;
      };
      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };
      urgency_low = {
        background = templateVars."common_ui_color_palette.blue.background";
        foreground = templateVars."common_ui_color_palette.neutral.muted";
        timeout = 10;
      };
      urgency_normal = {
        background = templateVars."common_ui_color_palette.blue.surface";
        foreground = templateVars."common_ui_color_palette.neutral.text";
        timeout = 10;
      };
      urgency_critical = {
        background = templateVars."common_ui_color_palette.status.red";
        foreground = templateVars."common_ui_color_palette.neutral.text";
        frame_color = templateVars."common_ui_color_palette.status.red_urgent";
        timeout = 0;
      };
    };
  };

  services.picom = {
    enable = pkgs.stdenv.isLinux;
    backend = "xrender";
    vSync = true;
    shadow = true;
    shadowExclude = [
      "name = 'Notification'"
      "_GTK_FRAME_EXTENTS@:c"
      "class_g = 'i3-frame'"
      "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
      "_NET_WM_STATE@:32a *= '_NET_WM_STATE_STICKY'"
      "!I3_FLOATING_WINDOW@:c"
    ];
    fade = false;
    fadeDelta = 7;
    fadeSteps = [ 0.05 0.05 ];
    settings = {
      shadow-radius = 12;
      shadow-offset-x = -4;
      shadow-offset-y = 4;
      shadow-opacity = templateVars."common_ui_color_palette.shadow.opacity";
      shadow-red = templateVars."common_ui_color_palette.shadow.red";
      shadow-green = templateVars."common_ui_color_palette.shadow.green";
      shadow-blue = templateVars."common_ui_color_palette.shadow.blue";
      shadow-ignore-shaped = true;
      blur-background = false;
      blur-background-fixed = true;
      blur-kern = "7x7box";
      blur-background-exclude = [
        "class_g = 'i3-frame'"
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "_GTK_FRAME_EXTENTS@:c"
      ];
      inactive-opacity-override = true;
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      use-ewmh-active-win = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      dbe = false;
      glx-copy-from-front = false;
      unredir-if-possible = false;
      focus-exclude = [ ];
      detect-transient = true;
      detect-client-leader = true;
      invert-color-include = [ ];
      wintypes = {
        tooltip = { fade = true; shadow = false; opacity = 1.0; focus = true; };
        normal = { fade = true; shadow = true; opacity = 1.0; focus = true; };
        dock = { shadow = false; };
        dnd = { shadow = false; };
      };
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "Fira Code Regular";
      size = 15.0;
    };
    settings = {
      scrollback_lines = 2000;
      scrollback_pager_history_size = 300;
      term = "xterm-kitty";
      shell_integration = "enabled";
      show_hyperlink_targets = "yes";
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      cursor_blink_interval = "0.5";
      cursor_stop_blinking_after = 5;
      mouse_hide_wait = 5;
      click_interval = "0.5";
      select_by_word_characters = ":@-./_~?&=%+#";
      open_url_with = "default";
      allow_hyperlinks = "ask";
      notify_on_cmd_finish = "unfocused 10.0 notify";

      mark1_background = "gray";
      mark2_background = "orange";
      mark3_background = "red";

      enabled_layouts = "Tall, Fat, Grid, Splits, Stack";

      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_background = templateVars."common_ui_color_palette.blue.background";
      active_tab_foreground = templateVars."common_ui_color_palette.blue.background";
      active_tab_background = templateVars."common_ui_color_palette.blue.focus";
      active_tab_font_style = "bold";
      inactive_tab_foreground = templateVars."common_ui_color_palette.neutral.muted";
      inactive_tab_background = templateVars."common_ui_color_palette.blue.surface";
      inactive_tab_font_style = "normal";
      tab_title_template = " {index}: {title} ";
      active_tab_title_template = " {fmt.bold}{index}: {title}{fmt.nobold} ";

      disable_ligatures = "cursor";

      bold_font = "Fira Code Bold";
      italic_font = "Fira Code Light";
      bold_italic_font = "Fira Code SemiBold";

      macos_option_as_alt = "left";

      background = templateVars."common_ui_color_palette.blue.background";
      foreground = templateVars."common_ui_color_palette.terminal.foreground";
      cursor = templateVars."common_ui_color_palette.blue.focus";
      selection_background = templateVars."common_ui_color_palette.blue.surface_alt";
      selection_foreground = templateVars."common_ui_color_palette.terminal.foreground";

      color0 = templateVars."common_ui_color_palette.blue.background";
      color1 = templateVars."common_ui_color_palette.terminal.red";
      color2 = templateVars."common_ui_color_palette.terminal.green";
      color3 = templateVars."common_ui_color_palette.terminal.yellow";
      color4 = templateVars."common_ui_color_palette.blue.focus";
      color5 = templateVars."common_ui_color_palette.terminal.magenta";
      color6 = templateVars."common_ui_color_palette.terminal.cyan";
      color7 = templateVars."common_ui_color_palette.terminal.white";
      color8 = templateVars."common_ui_color_palette.blue.surface_alt";
      color9 = templateVars."common_ui_color_palette.terminal.orange";
      color10 = templateVars."common_ui_color_palette.terminal.muted_green";
      color11 = templateVars."common_ui_color_palette.terminal.muted_yellow";
      color12 = templateVars."common_ui_color_palette.blue.focus_light";
      color13 = templateVars."common_ui_color_palette.terminal.violet";
      color14 = templateVars."common_ui_color_palette.neutral.muted";
      color15 = templateVars."common_ui_color_palette.terminal.bright_white";
    };
    keybindings = {
      "ctrl+shift+r" = "focus_visible_window";
      "f1" = "create_marker";
      "f2" = "toggle_marker function kitty-hintsconfig/kitty-hintsconfig.py";
      "ctrl+p" = "scroll_to_mark prev";
      "ctrl+n" = "scroll_to_mark next";
      "ctrl+shift+semicolon" = "kitten unicode_input --tab name";
      "ctrl+shift+colon" = "kitty_shell window";
      "f4" = "launch --allow-remote-control kitty +kitten broadcast";
      "ctrl+shift+o" = "kitten hints --customize-processing ~/.config/kitty/kitty-hintsconfig/kitty-hintsconfig.py";
      "ctrl+shift+e" = "kitten hints --type url";
      "ctrl+shift+y" = "kitten hints --type hyperlink";
      "ctrl+shift+p>f" = "kitten hints --type path --program -";
      "ctrl+shift+p>l" = "kitten hints --type line --program -";
      "ctrl+shift+p>w" = "kitten hints --type word --program -";
      "ctrl+shift+p>n" = "kitten hints --type linenum";
      "f3" = "kitten themes";
      "ctrl+shift+h" = "show_scrollback";
      "ctrl+shift+j" = "next_window";
      "ctrl+shift+k" = "previous_window";
      "ctrl+shift+f" = "move_window_forward";
      "ctrl+shift+l" = "next_layout";
      "ctrl+shift+d" = "detach_tab";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+q" = "close_window";
      "ctrl+shift+a" = "set_tab_title";
      "ctrl+shift+z" = "toggle_window_title_bars";
      "f5" = "toggle_layout stack";
    };
    extraConfig = ''
      font_features FiraCode +ss03 +ss05 +ss07
      font_features FiraCode-Regular +ss03 +ss05 +ss07
      font_features FiraCode-Bold +ss03 +ss05 +ss07
      font_features FiraCode-Light +ss03 +ss05 +ss07
      font_features FiraCode-SemiBold +ss03 +ss05 +ss07
      include local.conf
    '';
  };

  programs.rofi = {
    enable = pkgs.stdenv.isLinux;
    font = "Noto Sans Medium 12";
    extraConfig = {
      show-icons = true;
    };
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        "*" = {
          background = mkLiteral "${templateVars."common_ui_color_palette.blue.background"}";
          lightbg = mkLiteral "${templateVars."common_ui_color_palette.blue.surface_alt"}";
          lightfg = mkLiteral "${templateVars."common_ui_color_palette.blue.surface"}";
          foreground = mkLiteral "${templateVars."common_ui_color_palette.neutral.muted"}";
          separatorcolor = mkLiteral "${templateVars."common_ui_color_palette.neutral.muted"}";
          blue = mkLiteral "${templateVars."common_ui_color_palette.blue.focus"}";
          red = mkLiteral "${templateVars."common_ui_color_palette.status.red"}";

          background-color = mkLiteral "var(background)";
          border-color = mkLiteral "var(separatorcolor)";

          normal-background = mkLiteral "var(lightfg)";
          normal-foreground = mkLiteral "var(foreground)";

          alternate-normal-background = mkLiteral "var(lightbg)";
          alternate-normal-foreground = mkLiteral "var(foreground)";

          selected-normal-background = mkLiteral "var(blue)";
          selected-normal-foreground = mkLiteral "var(background)";

          urgent-background = mkLiteral "var(red)";
          urgent-foreground = mkLiteral "var(foreground)";
          selected-urgent-background = mkLiteral "var(red)";
          selected-urgent-foreground = mkLiteral "var(background)";
          alternate-urgent-background = mkLiteral "var(red)";
          alternate-urgent-foreground = mkLiteral "var(foreground)";

          active-background = mkLiteral "var(blue)";
          active-foreground = mkLiteral "var(foreground)";
          selected-active-background = mkLiteral "var(blue)";
          selected-active-foreground = mkLiteral "var(background)";
          alternate-active-background = mkLiteral "var(blue)";
          alternate-active-foreground = mkLiteral "var(foreground)";
        };

        "window" = {
          background-color = mkLiteral "var(background)";
          border-radius = 8;
          border = 0;
          width = mkLiteral "50%";
          location = mkLiteral "center";
          anchor = mkLiteral "center";
        };

        "mainbox" = {
          border = 0;
          padding = 0;
        };

        "inputbar" = {
          background-color = mkLiteral "var(background)";
          text-color = mkLiteral "var(foreground)";
          spacing = 2;
          padding = 12;
          children = map mkLiteral [ "prompt" "entry" "case-indicator" ];
        };

        "entry" = {
          text-color = mkLiteral "var(foreground)";
        };

        "prompt" = {
          text-color = mkLiteral "var(foreground)";
        };

        "case-indicator" = {
          text-color = mkLiteral "var(separatorcolor)";
        };

        "listview" = {
          background-color = mkLiteral "var(background)";
          border = 0;
          padding = 4;
          spacing = 2;
          layout = mkLiteral "vertical";
          dynamic = true;
          cycle = true;
        };

        "element" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "var(foreground)";
          padding = mkLiteral "6px 12px";
          border-radius = 4;
          border = 0;
        };

        "element normal.normal" = {
          background-color = mkLiteral "var(normal-background)";
          text-color = mkLiteral "var(normal-foreground)";
        };

        "element selected" = {
          background-color = mkLiteral "var(blue)";
          text-color = mkLiteral "var(background)";
        };

        "element selected.normal" = {
          background-color = mkLiteral "var(selected-normal-background)";
          text-color = mkLiteral "var(selected-normal-foreground)";
        };

        "element selected.urgent" = {
          background-color = mkLiteral "var(selected-urgent-background)";
          text-color = mkLiteral "var(selected-urgent-foreground)";
        };

        "element selected.active" = {
          background-color = mkLiteral "var(selected-active-background)";
          text-color = mkLiteral "var(selected-active-foreground)";
        };

        "element alternate" = {
          background-color = mkLiteral "var(lightbg)";
        };

        "element alternate.normal" = {
          background-color = mkLiteral "var(alternate-normal-background)";
          text-color = mkLiteral "var(alternate-normal-foreground)";
        };

        "element urgent" = {
          background-color = mkLiteral "var(red)";
          text-color = mkLiteral "var(foreground)";
        };

        "element-text" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
        };

        "element-icon" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
        };

        "scrollbar" = {
          handle-color = mkLiteral "var(blue)";
          handle-width = 4;
        };

        "button" = {
          background-color = mkLiteral "var(lightbg)";
          text-color = mkLiteral "var(foreground)";
        };

        "button selected" = {
          background-color = mkLiteral "var(blue)";
          text-color = mkLiteral "var(background)";
        };

        "mode-switcher" = {
          background-color = mkLiteral "var(lightbg)";
          spacing = 2;
          padding = 6;
        };

        "message" = {
          background-color = mkLiteral "var(lightbg)";
          text-color = mkLiteral "var(foreground)";
          border = 0;
        };
      };
  };

  services.redshift = {
    enable = lib.mkDefault pkgs.stdenv.isLinux;
    provider = "manual";
    latitude = 48.86;
    longitude = 2.3333;
    temperature = {
      day = 5500;
      night = 3500;
    };
    settings = {
      redshift = {
        gamma = 0.8;
        transition = 1;
        "adjustment-method" = "randr";
      };
    };
  };

  home.pointerCursor = lib.mkIf pkgs.stdenv.isLinux {
    name = "material_light_cursors";
    package = pkgs.material-cursors;
    x11.enable = true;
    gtk.enable = true;
  };

  # Additional static config files from common_ui files
  home.file.".sshbashrc".source = ../templates/kitty-ssh-bashrc;
  xdg.configFile."kitty/ssh.conf".source = ../templates/kitty-ssh.conf;

  # Clone/fetch kitty-hintsconfig
  xdg.configFile."kitty/kitty-hintsconfig".source = pkgs.runCommand "kitty-hintsconfig-patched" { } ''
    mkdir -p $out
    cp -r ${inputs.kitty-hintsconfig}/* $out/
    chmod +w $out/kitty-hintsconfig.py
    substituteInPlace $out/kitty-hintsconfig.py \
      --replace "'/run/current-system/sw/bin/python'" "'${pkgs.python3.withPackages (ps: [ ps.pyyaml ])}/bin/python'"
  '';

  # Custom script for polybar custom module
  xdg.configFile."polybar/custom" = {
    source = ../templates/polybar-custom;
    executable = true;
  };

  # Autostart script for i3
  xdg.configFile."i3/autostart.sh" = {
    text = ''
      #!/usr/bin/env bash
      # i3 Autostart Programs
      snixembed --fork
      nm-applet &
      blueman-applet &
      xfce4-clipman &
      hp-systray &
      tailscale systray &
    '';
    executable = true;
  };

  # Systemd user targets
  systemd.user.targets.i3-session = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "i3 session";
      BindsTo = [ "graphical-session.target" ];
    };
  };

  # GTK theme configuration
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    font = {
      name = "Noto Sans 12";
    };
    gtk2.extraConfig = "gtk-key-theme-name = \"Emacs\"";
    gtk3.extraConfig = {
      gtk-key-theme-name = "Emacs";
    };
    gtk4.extraConfig = {
      gtk-key-theme-name = "Emacs";
    };
  };

  # Cocoa KeyBindings (Darwin specific)
  home.file."Library/KeyBindings/DefaultKeyBinding.dict" = lib.mkIf pkgs.stdenv.isDarwin {
    text =
      let
        original = builtins.readFile "${inputs.emacs-keybindings-in-osx}/DefaultKeybinding.dict";
        patchedLines = ''
          "\Uf72b"  = "moveToEndOfDocument:"; // End
          "\Uf72c"  = "pageUp:"; // PageUp
          "\Uf72d"  = "pageDown:"; // PageDown
          "\Uf729"  = "moveToBeginningOfDocument:"; // Home
          "$\Uf729" = "moveToBeginningOfDocumentAndModifySelection:"; // Shift+Home
          "$\Uf72b" = "moveToEndOfDocumentAndModifySelection:"; // Shift+End
        '';
      in
      builtins.replaceStrings [ "{\n" ] [ "{\n${patchedLines}" ] original;
  };
}
