{ config, lib, pkgs, modulesPath, ... }:
let
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in
{
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "uas" ];
#  boot.initrd.systemd.enable = true;
#  boot.initrd.systemd.repart.enable = true;
  imports = [ "${modulesPath}/image/repart.nix" ];
  fileSystems."/".device = "/dev/disk/by-label/nixos";
  boot.loader.efi.efiSysMountPoint = "/efi";
  systemd.repart = {
    enable = true;
    partitions = {
      "10-esp" = { Type = "esp"; };
      "20-root" = { Type = "root"; };
    };
  };
  image.repart = {
    name = "image";
    compression.enable = true;
    partitions = {
      "esp" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
            "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

          "/loader/entries/nixos.conf".source = pkgs.writeText "nixos.conf" ''
            title NixOS
            linux /EFI/nixos/kernel.efi
            initrd /EFI/nixos/initrd.efi
            options init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}
          '';

          "/EFI/nixos/kernel.efi".source =
            "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";

          "/EFI/nixos/initrd.efi".source =
            "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          SizeMinBytes = "500M";
        };
      };
      "root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Format = "ext4";
          Label = "nixos";
          Minimize = "guess";
        };
      };
    };
  };
}
