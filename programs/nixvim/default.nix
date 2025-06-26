{inputs, ...}: {
  imports = [
    inputs.nixvim.homeModules.nixvim

    ./options.nix
  ];
}
