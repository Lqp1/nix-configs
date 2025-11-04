{ inputs, pkgs, ... }:
let
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
in
{
  _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
  environment.systemPackages = with pkgs; [
    ansible
    autojump
    bat
    bc
    btop
    coreutils
    curl
    delta
    dfc
    eza
    git
    gnugrep
    gnused
    gnutar
    go
    gopls
    home-manager
    htop
    httpie
    iftop
    lazygit
    less
    lsof
    mdcat
    moreutils
    my-python
    my-ruby
    netcat-gnu
    nil
    nvd
    pciutils
    pipx
    rclone
    ripgrep
    screen
    smount
    sshfs
    tig
    tree
    vgrep
    vim
    yazi
  ];

  programs.zsh.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;
  nixpkgs.config.allowUnfree = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

}
