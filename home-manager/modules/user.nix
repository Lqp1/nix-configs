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
      run ${pkgs.python3}/bin/python3 ${../scripts/setup-environment.py} --git-bin ${pkgs.git}/bin/git
    '';
  };
}
