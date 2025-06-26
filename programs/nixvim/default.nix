{inputs, pkgs, ...}: {
  imports = [
    ./options.nix
  ];

  # Installation
  home.packages = pkgs.lib.mkAfter home.packages ++ [
    inputs.nixvim.homeModules.nixvim
  ];
}
