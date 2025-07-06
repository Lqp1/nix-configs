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
          # Why needing hatchling manually ? it works oob on Linux but not on macOS
          buildInputs = old.buildInputs ++ [ pkgsUnstable.python3Packages.hatchling ];
          # Personal fork of rofimoji to fix the tool on MacOS to support "choose" and "pbcopy" commands
          version = old.version + "-lqp1-e86";
          src = pkgs.fetchFromGitHub {
             owner = "lqp1";
             repo = "rofimoji";
             rev = "e86d1814e86b0f8f97a8b14378d98f62a54fd9e5";
             sha256 = "sha256-W3D+8RLmx7Tq7DSsjN/OfjAqbN0NltdDubATqlP9LTg=";
             };
          # Force support of darwin and linux platforms now
          meta = old.meta // { platforms = pkgs.lib.platforms.linux ++ pkgs.lib.platforms.darwin;};
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
