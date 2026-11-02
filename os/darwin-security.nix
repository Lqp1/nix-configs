# Security hardening for Darwin workstations
{ ... }:
{
  security.pam.services.sudo_local.touchIdAuth = true;
  system.defaults.loginwindow.GuestEnabled = false;

  # https://emudhra.we-have-a-problem.com/
  # Python's ssl module ignores NIX_SSL_CERT_FILE; point it (and uv, which
  # embeds its own bundle) at the system bundle with the blacklist applied.
  environment.variables = {
    REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    UV_SYSTEM_CERTS = "true";
  };
}
