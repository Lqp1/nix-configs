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
  my-kitty = pkgs.kitty.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs ++ [ my-python ];
  });
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
    moreutils
    pciutils
    delta
    tig
    bat
    lsof
    bc
    ansible
    btop
    my-kitty
    eza
    vgrep
    coreutils
    home-manager
    pipx
    autojump
    iftop
    lazygit
    httpie
    ripgrep
    less
    httpie
    lazygit
    # choose-gui
    go
    gopls
    my-ruby
    my-python
    gnutar
    gnugrep
    smount
  ];

  programs.zsh.enable = true;
  fonts.packages = [ pkgs.fira-code pkgs.noto-fonts pkgs.noto-fonts-cjk-sans pkgs.noto-fonts-emoji ];
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;
  nixpkgs.config.allowUnfree = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

}
