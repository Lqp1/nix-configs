{ inputs, pkgs, ... }:
let
  inherit (inputs.smount.packages.${pkgs.stdenv.hostPlatform.system}) smount;
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
  ] ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [ i3ipc ]);
  my-python = pkgs.python3.withPackages my-python-packages;
  my-ruby = pkgs.ruby.withPackages (ps: with ps; [ rubocop pry rspec solargraph ]);
in
{
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
    fzf
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
    jq
    lazygit
    less
    lsof
    mdcat
    moreutils
    my-python
    my-ruby
    netcat-gnu
    nil
    pciutils
    #pipx # Keep it for future reference but not used anymore and broken for now in 26.05
    rclone
    ripgrep
    screen
    smount
    sshfs
    statix
    tig
    tree
    vgrep
    vim
    yazi
    yq
  ];

  programs.bash.interactiveShellInit = ''
    __prompt_command() {
      local nix_info=""
      local shlvl_info=""

      if [ -n "$IN_NIX_SHELL" ]; then
        nix_info=" \[\e[35m\][nix:$IN_NIX_SHELL]\[\e[0m\]"
      fi

      if [ "''${SHLVL:-1}" -gt 1 ]; then
        shlvl_info=" \[\e[33m\][shlvl:$SHLVL]\[\e[0m\]"
      fi

      PS1="\[\e[32m\]\u@\h\[\e[0m\]''${nix_info}''${shlvl_info}: \[\e[34m\]\w\[\e[0m\] \$ "
    }

    PROMPT_COMMAND=__prompt_command
  '';
  programs.zsh.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;
  nix.settings.auto-optimise-store = false;
  nixpkgs.config.allowUnfree = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

}
