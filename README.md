nix flake update --commit-lock-file

nix run nix-darwin -- switch --flake .
sudo nixos-rebuild --flake . switch

