{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    keepassxc
    kitty
    unstable.rofimoji

    # For Neovim/Lazyvim
    neovim # Defined already in ./linux-workstation.nix but needed for darwin too
    gcc # Treesitter
    nodejs # Copilot.ai
  ];

  fonts.packages = [ pkgs.fira-code pkgs.noto-fonts pkgs.noto-fonts-cjk-sans pkgs.noto-fonts-color-emoji ];
}
