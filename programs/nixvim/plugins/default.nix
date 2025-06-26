{ pkgs, ... }:
{
    imports = [
      ./lualine.nix
      ./telescope.nix
      ./web-devicons.nix
      ./treesitter.nix
      ./neo-tree.nix
    ];
}
