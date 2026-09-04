{
  description = "NixOS bootstrap configuration for low RAM VPS";

  inputs = {
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko/pull/1277/head";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    {
      disko,
      nixpkgs,
      preservation,
      self,
    }:

    {
      nixosConfigurations = {
        legacy = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            preservation.nixosModules.preservation
            ./legacy.nix
            ./shared.nix
          ];
        };
        uefi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            preservation.nixosModules.preservation
            ./uefi.nix
            ./shared.nix
          ];
        };
      };

      checks.x86_64-linux = {
        legacy-install = self.nixosConfigurations.legacy.config.system.build.installTest;
        uefi-install = self.nixosConfigurations.uefi.config.system.build.installTest;
      };

      packages.x86_64-linux = {
        legacy = self.nixosConfigurations.legacy.config.system.build.diskoImages;
        uefi = self.nixosConfigurations.uefi.config.system.build.diskoImages;
      };
    };
}
