{inputs, ...}: {
  imports = [
    ./options.nix
  ];

  # Installation
  home.packages = home.packages ++ [
    inputs.nixvim.homeModules.nixvim
  ];
}
