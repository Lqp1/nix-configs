{ ... }:
{
  fileSystems."/tmp" =
    {
      device = "tmpfs";
      options = [ "nodev" "nosuid" "nodiratime" "noatime" "size=2G" ];
      fsType = "tmpfs";
    };

  fileSystems."/run" =
    {
      device = "tmpfs";
      options = [ "nodev" "nosuid" "nodiratime" "noatime" "size=2G" ];
      fsType = "tmpfs";
    };

  fileSystems."/var/tmp" =
    {
      device = "tmpfs";
      options = [ "nodev" "nosuid" "nodiratime" "noatime" "size=2G" ];
      fsType = "tmpfs";
    };
}
