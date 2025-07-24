{
  description = "Personal system flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
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
    {
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      darwinConfigurations."FV3Y4FYJ31" = nix-darwin.lib.darwinSystem {
        modules = [
          ./os/darwin-base.nix
          ./base.nix
          ./workstation.nix
          ./hosts/FV3Y4FYJ31.nix
          ./work.nix
        ];
        specialArgs = { inherit inputs; };
      };
      nixosConfigurations."thomas-x201" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
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
          ./os/linux-base.nix
          ./os/linux-workstation.nix
          ./base.nix
          ./workstation.nix
          ./hosts/t460.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t460
        ];
        specialArgs = { inherit inputs; };
      };
      nixosConfigurations."wsl" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          ./os/linux-base.nix
          ./os/linux-headless.nix
          ./base.nix
          ./hosts/wsl.nix
        ];
        specialArgs = { inherit inputs; };
      };
      nixosConfigurations."thomas-desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
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
