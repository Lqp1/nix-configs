{ inputs, pkgs, ... }:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
  smount = inputs.smount.packages.${pkgs.system}.smount;
  my-python-packages = python-packages: with python-packages; [
    pip
    configargparse
    flake8
    autopep8
    pylint
    python-lsp-server
    ipython
    ipdb
    pyyaml
    lxml
    consul
    requests
    six
    i3ipc
  ];
  my-python = pkgs.python3.withPackages my-python-packages;
  my-ruby = pkgs.ruby.withPackages (ps: with ps; [ rubocop pry rspec solargraph ]);
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
    curl
    vim
    git
    keepassxc
    htop
    dfc
    tree
    screen
    rclone
    sshfs
    kitty
    moreutils
    pciutils
    delta
    tig
    bat
    lsof
    bc
    ansible
    btop
    eza
    vgrep
    coreutils
    home-manager
    pipx
    mdcat
    autojump
    iftop
    lazygit
    httpie
    ripgrep
    less
    httpie
    lazygit
    go
    gopls
    netcat-gnu
    gnutar
    gnugrep
    gnused
    smount
    yazi
    my-ruby
    my-python
    my-rofimoji
  ];

  programs.zsh.enable = true;
  fonts.packages = [ pkgs.fira-code pkgs.noto-fonts pkgs.noto-fonts-cjk-sans pkgs.noto-fonts-emoji ];
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;
  nixpkgs.config.allowUnfree = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

}
