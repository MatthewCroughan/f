{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  inputs.nixos-hardware.url = "github:nixos/nixos-hardware";
  outputs = { self, nixpkgs, nixos-hardware }: rec {
    images.timbo-image = nixosConfigurations.timbo.config.system.build.image;
    nixosConfigurations.timbo = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.common-pc-laptop-ssd
        nixos-hardware.nixosModules.common-hidpi
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-nvidia
        nixos-hardware.nixosModules.common-gpu-amd
        ./configuration.nix
        ./repart.nix
      ];
    };
  };
}
