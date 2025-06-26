{inputs, ...}: {
  imports = [];

  # Installation
  home.packages = [
    inputs.nixvim.homeModules.nixvim
  ];
}
