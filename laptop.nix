{ inputs, pkgs, pkgsUnstable, ... }:
{
  services.tlp.enable = true;

  services.usbguard = {
    enable = true;
    implicitPolicyTarget = "block";
    presentControllerPolicy = "allow";
    presentDevicePolicy = "allow";
    insertedDevicePolicy = "apply-policy";
    IPCAllowedGroups = [ "wheel" ];
  };
}
