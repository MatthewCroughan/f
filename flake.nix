{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    disko.url = "github:nix-community/disko";
    disko-utils.url = "github:matthewcroughan/disko-utils";
  };

  outputs = { self, nixpkgs, nixos-hardware, disko-utils, disko }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.autoInstaller =
      (pkgs.writeShellScriptBin "diskoScript" ''
        set -e
        PATH=${pkgs.nix}/bin:$PATH
        ${self.nixosConfigurations.timbo.config.system.build.diskoScript}
        ${pkgs.nixos-install-tools}/bin/nixos-install --no-root-password --option substituters "" --no-channel-copy --system ${self.nixosConfigurations.timbo.config.system.build.toplevel}
        ${pkgs.coreutils}/bin/cp --no-preserve=mode -rT ${self} /mnt/etc/nixos
        ${pkgs.umount}/bin/umount /mnt/boot /mnt
      '');
    nixosConfigurations.timbo = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.common-pc-laptop-ssd
        nixos-hardware.nixosModules.common-hidpi
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-nvidia
        nixos-hardware.nixosModules.common-gpu-amd
        disko.nixosModules.disko
        ./configuration.nix
        ./disko.nix
#        ./repart.nix
      ];
    };
  };
}
