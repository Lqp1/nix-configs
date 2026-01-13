{ inputs, pkgs, pkgsUnstable, ... }:
let
  # Use rofimoji from nixpkgs-unstable because rofi dep is hardcoded in 24.11 and not compatible with darwin
  my-rofimoji = (pkgsUnstable.rofimoji.overrideAttrs (old: {
    # Use main branch which contains my patch for MacOS; it required hatchling to build now
    buildInputs = old.buildInputs ++ [ pkgsUnstable.python3Packages.hatchling ];
    version = old.version + "-1438d04";
    src = pkgs.fetchFromGitHub {
      owner = "fdw";
      repo = "rofimoji";
      rev = "1438d048bbe4477ac6383c29a8f520300bacdafc";
      sha256 = "sha256-AJM0XvDe+L8o7SKwGTug+M5Un5G3K0NHYPDLrUalDbY=";
    };
    # Force support of darwin and linux platforms now
    meta = old.meta // { platforms = pkgs.lib.platforms.linux ++ pkgs.lib.platforms.darwin; };
  }
  )).override {
    waylandSupport = false;
    x11Support = false;
  };
in
{
  environment.systemPackages = with pkgs; [
    keepassxc
    kitty
    my-rofimoji

    # For Neovim/Lazyvim
    neovim # Defined already in ./linux-workstation.nix but needed for darwin too
    gcc # Treesitter
    nodejs # Copilot.ai
  ];

  fonts.packages = [ pkgs.fira-code pkgs.noto-fonts pkgs.noto-fonts-cjk-sans pkgs.noto-fonts-color-emoji ];
}
