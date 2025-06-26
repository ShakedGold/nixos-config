{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;

    plugins.lualine.enable = true;
  };
}
