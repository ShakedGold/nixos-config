{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;

      settings = {
        indent.enable = true;
        highlight.enable = true;
      };

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        lua
        javascript
        nix
      ];
    };
  };
}
