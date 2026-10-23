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

  # Python's ssl module ignores NIX_SSL_CERT_FILE; point it (and uv, which
  # embeds its own bundle) at the system bundle with the blacklist applied.
  environment.variables = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    UV_SYSTEM_CERTS = "true";
  };
}
