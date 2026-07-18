{ pkgs, lib, ... }:

{
  # Default mime associations (replaces xdg-mime commands)
  xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "image/jpeg" = [ "org.xfce.ristretto.desktop" ];
      "image/png" = [ "org.xfce.ristretto.desktop" ];
    };
    associations.added = {
      "image/jpeg" = [ "org.gnome.gThumb.desktop" ];
    };
  };

  home.file = {
    ".smount/01personal" = {
      text = ''
        variables:
            pim: "prompt: Enter PIM:"
        mount_types:
            rclone:
                mount: rclone mount $src $target --daemon --vfs-cache-mode writes --dir-cache-time
                    10s --attr-timeout 1s --vfs-read-chunk-size 16M --vfs-cache-max-size 1G
                    --vfs-cache-max-age 30m
                umount: umount $target
            ssh:
                mount: sshfs -o reconnect,idmap=user,uid=$uid,gid=$gid thomas@192.168.1.4:$src
                    $target
                umount: umount $target
            veracrypt:
                mount: veracrypt --text --mount -mro --fs-options=iocharset=utf8 --keyfiles=""
                    --pim=$pim $src $target
                umount: veracrypt --text --dismount $src
        mounts:
            home:
                src: .
                target: /home/thomas/shares/home
                type: ssh
            share:
                src: assurancetourix:share
                target: /home/thomas/shares/share
                type: rclone
            vault:
                expand: last-alpha
                src: /home/thomas/Documents/Drive.hc.*
                target: /home/thomas/shares/vault
                type: veracrypt
      '';
    };
  } // (lib.optionalAttrs pkgs.stdenv.isLinux {
    "Bureau/tv.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Name=TV
        Type=Application
        Terminal=false
        Icon=video-x-generic
        Exec=vlc https://iptv-org.github.io/iptv/languages/fra.m3u
        Name[fr_FR.utf8]=TV
      '';
      executable = true;
    };

    "Bureau/Panoramix.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Link
        Name=Panoramix
        Icon=network-server
        URL=smb://thomas@192.168.1.4/
        Name[fr_FR.utf8]=Panoramix
      '';
      executable = true;
    };
  }) // (lib.optionalAttrs pkgs.stdenv.isDarwin {
    "Desktop/TV.command" = {
      text = ''
        #!/usr/bin/env bash
        open -a VLC "https://iptv-org.github.io/iptv/languages/fra.m3u"
      '';
      executable = true;
    };

    "Desktop/Panoramix.inetloc" = {
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        	<key>URL</key>
        	<string>smb://thomas@192.168.1.4/</string>
        </dict>
        </plist>
      '';
    };
  });

  # SSH Jump Host configs
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  # Autocreate mount points for smount and clone user repositories
  home.activation = {
    setupEnvironment = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create smount directories
      mkdir -p $HOME/shares/home
      mkdir -p $HOME/shares/share
      mkdir -p $HOME/shares/vault

      # Ensure Repo directory exists
      mkdir -p $HOME/Documents/Repo

      # Clone additional repositories if they do not exist
      if [ ! -d $HOME/Documents/Repo/spectre-meltdown-checker ]; then
        ${pkgs.git}/bin/git clone https://github.com/speed47/spectre-meltdown-checker $HOME/Documents/Repo/spectre-meltdown-checker
      fi

      if [ ! -d $HOME/Documents/Repo/kconfig-hardened-check ]; then
        ${pkgs.git}/bin/git clone https://github.com/a13xp0p0v/kconfig-hardened-check $HOME/Documents/Repo/kconfig-hardened-check
      fi

      if [ ! -d $HOME/Documents/Repo/lazyvim-config ]; then
        ${pkgs.git}/bin/git clone git@github.com:Lqp1/lazyvim-config.git $HOME/Documents/Repo/lazyvim-config
      fi

      if [ ! -d $HOME/.config/nvim ] && [ ! -L $HOME/.config/nvim ]; then
        mkdir -p $HOME/.config
        ln -sf $HOME/Documents/Repo/lazyvim-config $HOME/.config/nvim
      fi

      # Configure VeraCrypt default options if the configuration exists
      VC_FILE="$HOME/.config/VeraCrypt/Configuration.xml"
      if [ -f "$VC_FILE" ] && [ -s "$VC_FILE" ]; then
        ${pkgs.python3}/bin/python3 -c "
import xml.etree.ElementTree as ET
try:
    tree = ET.parse('$VC_FILE')
    root = tree.getroot()
    conf = root.find('configuration')
    if conf is not None:
        def set_key(key, val):
            for c in conf.findall('config'):
                if c.get('key') == key:
                    c.text = val
                    return
            new_c = ET.SubElement(conf, 'config', key=key)
            new_c.text = val
        set_key('MountVolumesReadOnly', '1')
        set_key('FilesystemOptions', 'iocharset=utf8')
        if hasattr(ET, 'indent'):
            ET.indent(tree, space='\t', level=0)
        tree.write('$VC_FILE', encoding='utf-8', xml_declaration=True)
except Exception:
    pass
"
      fi
    '';
  };
}
