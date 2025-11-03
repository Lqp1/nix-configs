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
    curl
    vim
    git
    htop
    dfc
    tree
    screen
    rclone
    sshfs
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
    nil
    autojump
    iftop
    lazygit
    httpie
    ripgrep
    less
    httpie
    lazygit
    nvd
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
  ];

  programs.zsh.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;
  nixpkgs.config.allowUnfree = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

}
