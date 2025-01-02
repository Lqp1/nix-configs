{
  description = "Work system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixos-hardware }:
    {
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      darwinConfigurations."FV3Y4FYJ31" = nix-darwin.lib.darwinSystem {
        modules = [
          ./darwin-base.nix
          ./base.nix
        ];
        specialArgs = { inherit inputs; };
      };
      nixosConfigurations."thomas-x201" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./linux-base.nix
          ./base.nix
          ./x201.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x200s
        ];
      };
    };
}
