{
# Instructions:

# To build with no intention of hacking the source code, do:
#   nix build .#x --impure
# If you are on an ubuntu machine, run it with:
#   nixGL result/bin/freecad

# To build for developing from your own source code, refer to
#   https://github.com/NixOS/nixpkgs/issues/215082#issuecomment-1662718432
# But have the code checked out, change and edit Dsrc and src
# Then do nix develop .#x --impure
#   genericBuild
# Put in the export environment variables and call bin/FreeCAD
# Recompile with ninjaBuildPhase

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixGL.url = "github:guibou/nixGL";
  };

  outputs = { self, nixpkgs, nixGL }:
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
  in
  {
    apps.x86_64-linux.freecad = {
      type = "app";
      program = builtins.toPath (pkgs.writeShellScript "sdkGL" ''
        export NIX_CONFIG="experimental-features = nix-command flakes"
        export PATH=$PATH:${pkgs.nixUnstable}/bin
        nix run --impure  ${nixGL}#nixGLDefault -- nix shell --impure ${self}#x --command "freecad"
      '');
    };
    x = (pkgs.freecad.overrideAttrs (old: {
      #cmakeFlags = old.cmakeFlags ++ [ "-DCMAKE_BUILD_TYPE=Debug" ];
      version = "freecad-flake";
      src = pkgs.fetchFromGitHub { owner = "goatchurchprime"; repo = "FreeCAD";
                rev = "103ed6a5fd6d2725475d9ad88b9f232b6cb7d7cb";
                hash = "sha256-4E8BsSmyECXFde+HYg7YLvhDqSUuVDQeDIdURj/Hpz0="; };
      buildInputs = old.buildInputs ++ [ pkgs.fmt ];
    })).override {
#      stdenv = pkgs.ccacheStdenv;
#      gfortran = pkgs.ccache.links { unwrappedCC = pkgs.gfortran // { lib = pkgs.gfortran; }; extraConfig = ":"; } // { inherit (pkgs.gfortran) cc; };
    };
  };
}
