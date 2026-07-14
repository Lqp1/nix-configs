{ ... }:

{
  # Default mime associations (replaces xdg-mime commands)
  xdg.mimeApps = {
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

  # TV and Samba Desktop launchers in ~/Bureau
  home.file."Bureau/tv.desktop" = {
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

  home.file."Bureau/Panoramix.desktop" = {
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

  home.file.".smount/01personal" = {
    text = ''
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
                  --pim=1557 $src $target
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

  # SSH Jump Host configs
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };
}
