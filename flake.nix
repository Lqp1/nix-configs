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
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , nix-darwin
    , nixos-hardware
    , flake-utils
    , ...
    }:
    let
      unstableOverlay = _final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      };

      overlayModule = {
        nixpkgs.overlays = [ unstableOverlay ];
      };

      commonSpecialArgs = { inherit inputs; };

      # NixOS system on linux with the workstation profile.
      mkLinuxWorkstation = { system ? "x86_64-linux", extraModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = commonSpecialArgs;
          modules = [
            overlayModule
            ./os/linux-base.nix
            ./os/linux-workstation.nix
            ./base.nix
            ./workstation.nix
          ] ++ extraModules;
        };

      # NixOS test VM (no workstation profile).
      mkTestVm = { system, extraModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = commonSpecialArgs;
          modules = [
            overlayModule
            ./os/linux-base.nix
            ./base.nix
            ./hosts/vm.nix
          ] ++ extraModules;
        };

      # Run-vm wrapper built with aarch64-darwin pkgs + HVF acceleration,
      # so `nix build .#vmImage` on macOS yields a native darwin script.
      darwinVmHostModule = {
        virtualisation.host.pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        virtualisation.qemu.options = [
          "-machine virt,accel=hvf,highmem=on"
          "-cpu host"
        ];
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
        specialArgs = commonSpecialArgs;
        modules = [
          overlayModule
          ./os/darwin-base.nix
          ./base.nix
          ./workstation.nix
          ./hosts/FV3Y4FYJ31.nix
        ];
      };

      nixosConfigurations = {
        "thomas-x201" = mkLinuxWorkstation {
          extraModules = [
            ./hosts/x201.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x200s
          ];
        };

        "thomas-t460" = mkLinuxWorkstation {
          extraModules = [
            ./hosts/t460.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-t460
          ];
        };

        "thomas-desktop" = mkLinuxWorkstation {
          extraModules = [ ./hosts/desktop.nix ];
        };

        test-vm = mkTestVm { system = "x86_64-linux"; };

        test-vm-darwin = mkTestVm {
          system = "aarch64-linux";
          extraModules = [ darwinVmHostModule ];
        };
      };

      packages.x86_64-linux.vmImage = self.nixosConfigurations.test-vm.config.system.build.vm;
      packages.aarch64-darwin.vmImage = self.nixosConfigurations.test-vm-darwin.config.system.build.vm;
    };
}
