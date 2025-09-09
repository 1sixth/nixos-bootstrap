{
  description = "NixOS bootstrap configuration for low RAM VPS";

  inputs = {
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  };

  outputs =
    {
      disko,
      impermanence,
      nixpkgs,
      self,
    }:

    {
      nixosConfigurations = {
        legacy = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
            ./legacy.nix
            ./shared.nix
          ];
        };
        uefi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
            ./uefi.nix
            ./shared.nix
          ];
        };
      };

      packages.x86_64-linux = {
        legacy = self.nixosConfigurations.legacy.config.system.build.diskoImages;
        uefi = self.nixosConfigurations.uefi.config.system.build.diskoImages;
      };
    };
}
