{
  description = "Personal system flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    smount.url = "github:lqp1/smount/main";
    smount.inputs.nixpkgs.follows = "nixpkgs";

    nixos-needsreboot.url = "https://codeberg.org/Mynacol/nixos-needsreboot/archive/main.tar.gz";
    nixos-needsreboot.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , nix-darwin
    , nixos-hardware
    , flake-utils
    , smount
    , nixos-needsreboot
    , ...
    }:
    let
      unstableOverlay = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      };

      overlayModule = {
        nixpkgs.overlays = [ unstableOverlay ];
      };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ unstableOverlay ];
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            deadnix
            omnix
          ];

          shellHook = ''
            echo "Nix config dev shell (${system})"
            echo "Useful commands:"
            echo "  nix fmt"
            echo "  deadnix ."
            echo "  statix check ."
            echo "  nix flake check"
            echo "  om ci"
          '';
        };
      })
    // {
      darwinConfigurations."FV3Y4FYJ31" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
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
        system = "x86_64-linux";
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
        system = "x86_64-linux";
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
        system = "x86_64-linux";
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
