{ pkgs, ... }:
{
    imports = [
      ./lualine.nix
      ./telescope.nix
      ./web-devicons.nix
      ./treesitter.nix
    ];
}
