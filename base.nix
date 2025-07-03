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
  my-rofimoji = (pkgsUnstable.callPackage
    # Use rofimoji from nixpkgs-unstable because rofi dep is hardcoded in 24.11 and not compatible with darwin
    (inputs.nixpkgs-unstable + "/pkgs/by-name/ro/rofimoji/package.nix")
    {
      waylandSupport = false;
      x11Support = false;
    }).overrideAttrs (old: {
          # Why needing hatchling manually ? it works oob on Linux but not on macOS
          buildInputs = old.buildInputs ++ [ pkgsUnstable.python3Packages.hatchling ];
          # Personal fork of rofimoji to fix the tool on MacOS to support "choose" and "pbcopy" commands
          src = pkgs.fetchFromGitHub {
             owner = "lqp1";
             repo = "rofimoji";
             rev = "c4af1bc211af63935fbe9364c36af25982efd506";
             sha256 = "sha256-dPM2VQg6TR3S7FmU6h7fp/PoNCBAkg2iGJbdM+f6eeY=";
             };
          # Force support of darwin and linux platforms now
          meta = old.meta // { platforms = pkgs.lib.platforms.linux ++ pkgs.lib.platforms.darwin;};
          }
  );
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
