{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;

    plugins.lualine.enable = true;
    extraPlugins = [ pkgs.vimPlugins.gruvbox ];
    colorscheme = "gruvbox";
  };
}
