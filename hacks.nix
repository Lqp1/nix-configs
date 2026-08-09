{ config, lib, pkgs, options, ... }:

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
      description = "Non-SUID sudo wrapper pointing to pkexec for tools with hardcoded sudo calls (e.g. VeraCrypt)";
    };
  };

  config = lib.mkMerge [
    (lib.optionalAttrs (options ? services && options.services ? udev) {
      services.udev.extraRules = lib.mkIf config.my.fprintMitigation ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="06cb", ATTR{idProduct}=="00fc", ATTR{power/control}="on"
      '';
    })

    (lib.optionalAttrs (options ? services && options.services ? tlp) {
      services.tlp.settings = lib.mkIf config.my.fprintMitigation {
        USB_DENYLIST = "06cb:00fc";
      };
    })

    (lib.optionalAttrs (options ? systemd && options.systemd ? services) {
      systemd.services.fprintd.serviceConfig = lib.mkIf config.my.fprintMitigation {
        TimeoutStopSec = "2s";
        Restart = "on-failure";
      };
    })

    (lib.optionalAttrs (options ? powerManagement) {
      powerManagement.resumeCommands = lib.mkIf config.my.fprintMitigation ''
        ${pkgs.systemd}/bin/systemctl try-restart fprintd.service || true
      '';
    })

    (lib.optionalAttrs (options ? security && options.security ? wrappers) {
      security.wrappers = lib.mkIf config.my.sudoWrapper {
        sudo = {
          owner = "root";
          group = "root";
          setuid = false;
          source = "${pkgs.writeScript "sudo" (builtins.readFile ./files/sudo)}";
        };
      };
    })
  ];
}
