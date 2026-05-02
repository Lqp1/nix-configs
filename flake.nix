{
  description = "Personal system flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    smount.url = "github:lqp1/smount/main";
    smount.inputs.nixpkgs.follows = "nixpkgs";
    nixos-needsreboot.url = "https://codeberg.org/Mynacol/nixos-needsreboot/archive/main.tar.gz";
    nixos-needsreboot.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-unstable, nixos-hardware, nixos-wsl, smount, nixos-needsreboot }:
    let
      unstableOverlay = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      };
      overlayModule = { nixpkgs.overlays = [ unstableOverlay ]; };
    in
    {
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      darwinConfigurations."FV3Y4FYJ31" = nix-darwin.lib.darwinSystem {
        modules = [
          overlayModule
          ./os/darwin-base.nix
          ./base.nix
          ./workstation.nix
          ./hosts/FV3Y4FYJ31.nix
        ];
        specialArgs = { inherit inputs; };
      };
      nixosConfigurations."thomas-x201" = nixpkgs.lib.nixosSystem {
        modules = [
          overlayModule
          ./os/linux-base.nix
          ./os/linux-workstation.nix
          ./base.nix
          ./workstation.nix
          ./hosts/x201.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x200s
        ];
        specialArgs = { inherit inputs; };
      };
      nixosConfigurations."thomas-t460" = nixpkgs.lib.nixosSystem {
        modules = [
          overlayModule
          ./os/linux-base.nix
          ./os/linux-workstation.nix
          ./base.nix
          ./workstation.nix
          ./hosts/t460.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t460
        ];
        specialArgs = { inherit inputs; };
      };
      nixosConfigurations."thomas-desktop" = nixpkgs.lib.nixosSystem {
        modules = [
          overlayModule
          ./os/linux-base.nix
          ./os/linux-workstation.nix
          ./base.nix
          ./workstation.nix
          ./hosts/desktop.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
