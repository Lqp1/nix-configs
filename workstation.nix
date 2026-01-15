{ inputs, pkgs, pkgsUnstable, ... }:
let
  # workaround waiting for https://github.com/NixOS/nixpkgs/pull/480317
  my-rofimoji = (pkgsUnstable.rofimoji.overrideAttrs (old: {
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
