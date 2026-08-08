{ config, lib, pkgs, ... }:

{
  options = {
    my.fprintMitigation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Workaround for Synaptics Prometheus fingerprint sensor USB autosuspend and sleep/resume deadlocks";
    };

    my.sudoWrapper = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Non-SUID sudo wrapper pointing to run0 for tools with hardcoded sudo calls (e.g. VeraCrypt)";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (config.my.fprintMitigation && pkgs.stdenv.isLinux) {
      # Prevent USB autosuspend and disconnects on the Synaptics Prometheus sensor
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="06cb", ATTR{idProduct}=="00fc", ATTR{power/control}="on"
      '';

      services.tlp.settings = {
        USB_DENYLIST = "06cb:00fc";
      };

      systemd.services.fprintd.serviceConfig = {
        TimeoutStopSec = "2s";
        Restart = "on-failure";
      };

      powerManagement.resumeCommands = ''
        ${pkgs.systemd}/bin/systemctl try-restart fprintd.service || true
      '';
    })

    (lib.mkIf (config.my.sudoWrapper && pkgs.stdenv.isLinux) {
      security.wrappers.sudo = {
        owner = "root";
        group = "root";
        setuid = false;
        source = "${pkgs.writeScript "sudo" (builtins.readFile ./files/sudo)}";
      };
    })
  ];
}
