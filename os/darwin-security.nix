# Security hardening for Darwin workstations
{ ... }:
{
  security.pam.services.sudo_local.touchIdAuth = true;
  system.defaults.loginwindow.GuestEnabled = false;

  # https://emudhra.we-have-a-problem.com/
  # Keep in sync with os/linux-security.nix
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
  ];
}
