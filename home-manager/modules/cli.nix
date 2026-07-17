{ config, pkgs, lib, inputs, ... }:

let
  home = config.home.homeDirectory;
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

  # Wrapped Neovim package to prepend runtime dependencies (gcc, nodejs)
  my-neovim = pkgs.symlinkJoin {
    name = "neovim-wrapped";
    paths = [ pkgs.neovim ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix PATH : ${lib.makeBinPath [ pkgs.gcc pkgs.nodejs ]}
    '';
  };
in
{
  home.packages = with pkgs; [
    ansible
    autojump
    bc
    ccze
    btop
    dfc
    go
    gopls
    htop
    httpie
    iftop
    jnv
    jq
    lazygit
    mdcat
    moreutils
    my-python
    my-ruby
    my-neovim
    netcat-gnu
    nil
    rclone
    smount
    sshfs
    statix
    tig
    tree
    vgrep
    yazi
    yq
  ];

  programs.bat = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--hidden"
      "--follow"
      "--max-columns=150"
      "--max-columns-preview"
      "--smart-case"
      "--glob=!{.git,.env,.venv,env,venv}"
    ];
  };

  programs.screen = {
    enable = true;
    screenrc = builtins.readFile ../templates/screenrc;
  };

  home.file.".vimrc".source = ../templates/vimrc;

  # ZSH Configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    envExtra = ''
      if [ -d ~/.profile.d ]; then
          for f in ~/.profile.d/*(N); do
              if [ -f "$f" ]; then
                  source "$f"
              fi
          done
      fi
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "colored-man-pages"
        "autojump"
        "fzf"
        "zsh-interactive-cd"
      ];
    };

    plugins = [
      {
        name = "zsh-autoenv";
        src = pkgs.zsh-autoenv;
        file = "share/zsh-autoenv/autoenv.zsh";
      }
    ];

    shellAliases = {
      ls = "eza --git --icons --hyperlink -F --color=auto";
      cp = "cp -iv";
      mv = "mv -iv";
      ip = "ip --color=auto";
      gits = "git status";
      gitd = "git diff";
      gitg = "git pull";
      gitp = "git push";
      gitw = "git log --no-merges --raw";
      gitl = "git tree";
      gite = "git ls-files -o -m --exclude-standard | fzf -m | xargs -r -o nvim";
      gitt = "git diff $(git rev-list -n1 --before=\"7:00\" master)";
      serve = "python3 -m http.server";
      bc = "bc -l";
      vi = "nvim";
      vim = "nvim";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      LESS = "-FSRXIW";
    };

    initContent = ''
      # Custom prompt with execution time (timed-cypher theme)
      setopt PROMPT_SUBST

      nix_prompt_info() {
        if [[ -n "$IN_NIX_SHELL" ]]; then
          echo "%{''${fg[magenta]}%}[nix:$IN_NIX_SHELL]%{''${reset_color}%} "
        fi
      }

      shlvl_prompt_info() {
        if [[ "$SHLVL" -gt 1 ]]; then
          echo "%{''${fg[yellow]}%}[shlvl:$SHLVL]%{''${reset_color}%} "
        fi
      }

      PROMPT='[%*] %m $(nix_prompt_info)$(shlvl_prompt_info)%{''${fg_bold[red]}%}:: %{''${fg[green]}%}%3~%(0?. . %{''${fg[red]}%}%? )%{''${fg[blue]}%}»%{''${reset_color}%} '

      preexec() {
        timer=$(($(date +%s%0N)/1000000))
      }

      precmd() {
        if [ $timer ]; then
          now=$(($(date +%s%0N)/1000000))
          elapsed=$((($now-$timer)/1000))

          hours=$(($elapsed/3600))
          min=$(($elapsed/60))
          sec=$(($elapsed%60))
          if [ "$elapsed" -le 1 ]; then
              timer_show=""
          elif [ "$elapsed" -le 60 ]; then
              timer_show="$elapsed s"
          elif [ "$elapsed" -gt 60 ] && [ "$elapsed" -le 180 ]; then
              timer_show="$min min. $sec s."
          else
              if [ "$hours" -gt 0 ]; then
                  min=$(($min%60))
                  timer_show="$hours h. $min min. $sec s."
              else
                  timer_show="$min min. $sec s."
              fi
          fi

          export RPROMPT="%F{cyan}''${timer_show}%{''${reset_color}%}"
          unset timer
        fi
      }

      # Helper for fzf-man
      fzf-man-widget() {
          if [ -z "$@" ]
          then
              \man -k . | fzf --prompt='Man> ' | awk '{print $1}' | xargs -r \man
          else
              \man $@
          fi
      }
      alias man='fzf-man-widget'

      # Helper for fzf-j (autojump)
      fzf-autojump-widget() {
          if [ -z "$@" ]
          then
              __fzf_autojump_target=$(cat "$HOME/.local/share/autojump/autojump.txt" 2>/dev/null | sort -nr | cut -f2 | fzf +s)
              if [ -n "$__fzf_autojump_target" ]; then
                  cd "$__fzf_autojump_target"
              fi
          else
              cd $(autojump $@)
          fi
      }
      alias j='fzf-autojump-widget'

      # Source custom alias scripts if they exist
      if [ -f ~/.bash_aliases ]; then
          source ~/.bash_aliases
      fi
      if [ -d ~/.aliases ]; then
          for f in ~/.aliases/*(N); do
              if [ -f "$f" ]; then
                  source "$f"
              fi
          done
      fi
    '';
  };

  # Git Configuration
  programs.git = {
    enable = true;
    ignores = [
      "TAGS"
      ".DS_Store"
      "Thumbs.db"
      "*~"
    ];
    settings = {
      user = {
        name = "Thomas Langé";
        email = "thomas.lange.oss@gmail.com";
      };
      alias = {
        tree = "log --graph --pretty=\"format:%ad %C(yellow)%h%Creset - %C(red)%an%Creset : %C(bold blue)%d%Creset %s\" --date=short";
        cleanup = "clean -dx -e .dir-locals.el -e .autoenv.zsh -e .autoenv_leave.zsh";
        vgrep = "!__git_vgrep () { git grep --color=always \"$@\" | vgrep; }; __git_vgrep";
        today = "log --since='6am' -p";
        root = "rev-parse --show-toplevel";
      };
      advice.skippedCherryPicks = false;
      pull.rebase = true;
      rebase.stat = true;
      rebase.autoStash = true;
      rebase.autoSquash = true;
      rebase.updateRefs = true;
      commit.verbose = true;
      column.ui = "auto";
      status.short = true;
      status.branch = true;
      core = {
        autocrlf = "input";
        safecrlf = "warn";
        pager = "less -FSRXIW";
        hooksPath = "/home/thomas/.githooks";
        attributesfile = "/home/thomas/.gitattributes";
      };
      help.autocorrect = 20;
      diff = {
        tool = "vimdiff";
        mnemonicPrefix = true;
        algorithm = "histogram";
        renames = true;
        colorMoved = "default";
      };
      difftool.prompt = false;
      merge.conflictstyle = "diff3";
      merge.tool = "vimdiff";
      rerere.enabled = true;
      rerere.autoupdate = true;
      push = {
        autoSetupRemote = true;
        followTags = true;
        default = "simple";
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgSign = true;
    };
  };

  # Delta Configuration
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      hunk-header-decoration-style = "none";
      syntax-theme = "Solarized (dark)";
      hyperlinks = true;
    };
  };

  # Git Attributes
  home.file.".gitattributes".text = ''
    *.c     diff=cpp
    *.c++   diff=cpp
    *.cc    diff=cpp
    *.cpp   diff=cpp
    *.cs    diff=csharp
    *.css   diff=css
    *.el    diff=lisp
    *.ex    diff=elixir
    *.exs   diff=elixir
    *.go    diff=golang
    *.h     diff=cpp
    *.h++   diff=cpp
    *.hh    diff=cpp
    *.hpp   diff=cpp
    *.html  diff=html
    *.js    diff=javascript
    *.lisp  diff=lisp
    *.m     diff=objc
    *.md    diff=markdown
    *.mm    diff=objc
    *.php   diff=php
    *.pl    diff=perl
    *.py    diff=python
    *.rake  diff=ruby
    *.rb    diff=ruby
    *.rs    diff=rust
    *.ts    diff=javascript
    *.xhtml diff=html
  '';





  # ~/.aliases configuration files
  home.file.".aliases/10kitty".source = ../templates/kittyaliases;
  home.file.".aliases/fzf-git.sh".source = "${inputs.fzf-git}/fzf-git.sh";
  home.file.".aliases/10vgrep".source = ../templates/vgrep;
  home.file.".aliases/11bat".source = ../templates/bat;
  home.file.".aliases/05secrets".source = ../templates/secrets;

  # Vim colorscheme configuration
  home.file.".vim/colors/solarized.vim".source = "${inputs.vim-solarized8}/colors/solarized8_flat.vim";

  # Curl configuration
  home.file.".curlrc".text = ''
    --location
    --compressed
  '';

  # Eza theme configuration
  xdg.configFile."eza/theme.yml".source = "${inputs.eza-themes}/themes/gruvbox-dark.yml";

  # Bash interactive shell prompt (moved from base.nix)
  programs.bash = {
    enable = true;
    profileExtra = ''
      if [ -d ~/.profile.d ]; then
          for f in ~/.profile.d/*; do
              [ -e "$f" ] && source "$f"
          done
      fi
    '';
    initExtra = ''
      __prompt_command() {
        local nix_info=""
        local shlvl_info=""

        if [ -n "$IN_NIX_SHELL" ]; then
          nix_info=" \[\e[35m\][nix:$IN_NIX_SHELL]\[\e[0m\]"
        fi

        if [ "''${SHLVL:-1}" -gt 1 ]; then
          shlvl_info=" \[\e[33m\][shlvl:$SHLVL]\[\e[0m\]"
        fi

        PS1=" \[\e[32m\]\u@\h\[\e[0m\]''${nix_info}''${shlvl_info}: \[\e[34m\]\w\[\e[0m\] \$ "
      }

      PROMPT_COMMAND=__prompt_command

      if [ -d ~/.aliases ]; then
          for f in ~/.aliases/*; do
              [ -e "$f" ] && source "$f"
          done
      fi
    '';
  };
}
