{ pkgs, ... }:
{

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "timbo";

  programs.singularity = {
    enable = true;
    enableSuid = true;
  };

  environment.systemPackages = with pkgs; [
    firefox
    python3
    vim
    git
    #freecad
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90;
  };

  nix.settings = {
    trusted-users = [ "@wheel root" ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  users.users.timbo = {
    isNormalUser = true;
    password = "default";
    extraGroups = [
      "input"
      "lp"
      "wheel"
      "dialout"
      "kvm"
      "plugdev"
    ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  hardware.nvidia.prime = {
    amdgpuBusId = "PCI:5:0:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  hardware.enableAllFirmware = true;

}
